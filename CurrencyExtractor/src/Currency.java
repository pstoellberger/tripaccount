import java.util.ArrayList;
import java.util.List;

public class Currency implements Comparable<Currency> {

	private String name;
	private String isoCode;
	private List<Country> countries = new ArrayList<Country>();
	private int numberOfDigitsAfterSep;
	private List<ExchangeRate> rates = new ArrayList<ExchangeRate>();

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getIsoCode() {
		return isoCode;
	}

	public void setIsoCode(String isoCode) {
		this.isoCode = isoCode;
	}

	public List<Country> getCountries() {
		return countries;
	}

	public void setCountries(List<Country> countries) {
		this.countries = countries;
	}

	public int getNumberOfDigitsAfterSep() {
		return numberOfDigitsAfterSep;
	}

	public void setNumberOfDigitsAfterSep(int numberOfDigitsAfterSep) {
		this.numberOfDigitsAfterSep = numberOfDigitsAfterSep;
	}

	public List<ExchangeRate> getRates() {
		return rates;
	}

	public void setRates(List<ExchangeRate> rates) {
		this.rates = rates;
	}

	@Override
	public String toString() {
		return "Currency [name=" + name + ", isoCode=" + isoCode + ", countries=" + countries + ", numberOfDigitsAfterSep=" + numberOfDigitsAfterSep
				+ "]";
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((isoCode == null) ? 0 : isoCode.hashCode());
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
		Currency other = (Currency) obj;
		if (isoCode == null) {
			if (other.isoCode != null)
				return false;
		} else if (!isoCode.equals(other.isoCode))
			return false;
		return true;
	}

	public int compareTo(Currency o) {
		return name.compareTo(o.getName());
	}

}
