import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class Country implements Comparable<Country> {

	private int id;
	private String name;
	private URL imgPath;
	private List<City> cities = new ArrayList<City>();

	public List<City> getCities() {
		return cities;
	}

	public void setCities(List<City> cities) {
		this.cities = cities;
	}

	public String getName() {
		return name;
	}

	public String getImgName() {
		return "flag" + id + ".png";
	}

	public void setName(String name) {
		if (name != null)
			this.name = name.trim();
	}

	public URL getImgPath() {
		return imgPath;
	}

	public void setImgPath(URL imgPath) {
		this.imgPath = imgPath;
	}

	@Override
	public String toString() {
		return "Country [name=" + name + ", imgPath=" + ((imgPath == null) ? "NO" : "YES") + "]";
	}

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
		Country other = (Country) obj;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		return true;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int compareTo(Country country) {
		return name.compareTo(country.getName());
	}
}
