package at.oenb.cycle;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Random;

import org.apache.log4j.Logger;
import org.junit.Test;

public class FindeZyklus {

	private static final int ABGESCHLOSSEN = 2;
	private static final int NOCH_NICHT_BEGONNEN = 0;
	private static final int IN_BEARBEITUNG = 1;

	private static final Logger LOGGER = Logger.getLogger(FindeZyklus.class
			.getName());

	private static class Knoten {
		public Knoten(String name) {
			super();
			this.name = name;
		}

		public String name;
		public int status;

		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + ((name == null) ? 0 : name.hashCode());
			return result;
		}

		@Override
		public boolean equals(Object obj) {
			if (this == obj)
				return true;
			if (obj == null)
				return false;
			if (getClass() != obj.getClass())
				return false;
			Knoten other = (Knoten) obj;
			if (name == null) {
				if (other.name != null)
					return false;
			} else if (!name.equals(other.name))
				return false;
			return true;
		}

		@Override
		public String toString() {
			return name;
		}

	}

	private static class Weg {

		public Knoten anfang;
		public Knoten ende;
		public int gewicht;

		public Weg(Knoten anfang, Knoten ende, int gewicht) {
			super();
			this.anfang = anfang;
			this.ende = ende;
			this.gewicht = gewicht;
		}

		@Override
		public String toString() {
			return anfang + "->" + ende;
		}

	}

	private static class Zyklus {

		public List<Weg> wegList = new ArrayList<Weg>();
		public int minWeight;

		public Zyklus(int minWeight) {
			super();
			this.minWeight = minWeight;
		}

		public Zyklus clone() {
			Zyklus zyklus = new Zyklus(minWeight);
			zyklus.wegList.addAll(wegList);
			return zyklus;
		}

		@Override
		public String toString() {
			StringBuffer buffer = new StringBuffer();
			for (Weg weg : wegList) {
				buffer.append(weg.anfang.name).append("-");
			}
			return buffer.toString();
		}
	}

	@Test
	public void testCycleOnce() {

		Knoten kA = new Knoten("A");
		Knoten kB = new Knoten("B");
		Knoten kC = new Knoten("C");
		Knoten kD = new Knoten("D");

		Weg w1 = new Weg(kA, kB, 12);
		Weg w2 = new Weg(kB, kC, 50);
		Weg w3 = new Weg(kC, kA, 14);
		Weg w4 = new Weg(kD, kB, 16);
		Weg w5 = new Weg(kC, kD, 20);

		ArrayList<Weg> wege = new ArrayList<Weg>();
		wege.add(w2);
		wege.add(w1);
		wege.add(w5);
		wege.add(w4);
		wege.add(w3);

		cycleRemoval(wege);
	}

	@Test
	public void testCycleRemovalRand() {

		Random r = new Random(42);

		for (int run = 0; run < 1000; run++) {

			ArrayList<Knoten> knoten = new ArrayList<Knoten>();
			int maxKnoten = r.nextInt(5) + 5;
			for (int i = 0; i < maxKnoten; i++) {
				knoten.add(new Knoten("Knoten" + i));
			}

			ArrayList<Weg> wege = new ArrayList<Weg>();

			int maxWeg = r.nextInt(50) + 10;
			for (int i = 0; i < maxWeg; i++) {
				Weg weg = new Weg(knoten.get(r.nextInt(knoten.size())),
						knoten.get(r.nextInt(knoten.size())), r.nextInt(30) + 1);

				boolean add = true;
				if (weg.anfang == weg.ende) {
					add = false;
				}
				for (Weg exWeg : wege) {
					if ((exWeg.anfang == weg.anfang && exWeg.ende == weg.ende)
							|| ((exWeg.anfang == weg.ende && exWeg.ende == weg.anfang))) {
						add = false;
					}
				}
				if (add) {
					wege.add(weg);
				}
			}

			LOGGER.info("Anzahl wege : " + wege.size());

			cycleRemoval(wege);
		}
	}

	public void cycleRemoval(List<Weg> wege) {

		for (Weg weg : wege) {
			LOGGER.info(String.format("%s (%s)", weg.toString(), weg.gewicht));
		}

		HashMap<Knoten, Integer> oldState = calcAccounts(wege);

		Zyklus z = null;
		while ((z = geheWeg(wege, wege.get(0).anfang, new Zyklus(1000))) != null) {
			for (Weg weg : z.wegList) {
				weg.gewicht -= z.minWeight;
				if (weg.gewicht == 0) {
					wege.remove(weg);
				}
			}
			for (Weg weg : wege) {
				weg.anfang.status = NOCH_NICHT_BEGONNEN;
				weg.ende.status = NOCH_NICHT_BEGONNEN;
			}
		}

		for (Weg weg : wege) {
			LOGGER.info(String.format("%s (%s)", weg.toString(), weg.gewicht));
		}

		assertEquals(oldState, calcAccounts(wege));

	}

	private HashMap<Knoten, Integer> calcAccounts(List<Weg> wege) {

		HashMap<Knoten, Integer> konto = new HashMap<Knoten, Integer>();
		for (Weg weg : wege) {
			if (konto.get(weg.anfang) == null) {
				konto.put(weg.anfang, 0);
			}
			if (konto.get(weg.ende) == null) {
				konto.put(weg.ende, 0);
			}
			konto.put(weg.anfang, konto.get(weg.anfang) - weg.gewicht);
			konto.put(weg.ende, konto.get(weg.ende) + weg.gewicht);
		}

		Iterator<Entry<Knoten, Integer>> it = konto.entrySet().iterator();
		while (it.hasNext()) {
			Entry<Knoten, Integer> entry = it.next();
			if (entry.getValue() == 0) {
				it.remove();
			}
		}

		for (Entry<Knoten, Integer> entry : konto.entrySet()) {
			LOGGER.info(String.format("Konto von %s = %s", entry.getKey().name,
					entry.getValue()));
		}

		return konto;
	}

	private Zyklus geheWeg(List<Weg> wege, Knoten knoten, Zyklus zyklus) {

		Zyklus returnZyklus = null;

		if (knoten.status == IN_BEARBEITUNG) {

			while (!zyklus.wegList.get(0).anfang.equals(knoten)) {
				zyklus.wegList.remove(0);
			}

			LOGGER.info(String.format("Zyklus gefunden: %s%s Gewicht:%s",
					zyklus, knoten.name, zyklus.minWeight));
			return zyklus;

		} else {

			if (knoten.status == NOCH_NICHT_BEGONNEN) {
				knoten.status = IN_BEARBEITUNG;

				for (Weg weg : wege) {
					if (weg.anfang.equals(knoten)) {
						Zyklus newZyklus = zyklus.clone();
						newZyklus.wegList.add(weg);
						newZyklus.minWeight = Math.min(weg.gewicht,
								zyklus.minWeight);
						returnZyklus = geheWeg(wege, weg.ende, newZyklus);
						if (returnZyklus != null) {
							break;
						}
					}
				}

				knoten.status = ABGESCHLOSSEN;
			}
		}

		return returnZyklus;
	}

}