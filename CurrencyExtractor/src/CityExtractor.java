import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

public class CityExtractor {

	public static final Pattern patternEntry = Pattern.compile("<tr>(.*?)</tr>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
	public static final Pattern patternPosition = Pattern.compile(
			"<td>([0-9NSWE\\°\\'\\′]*)</td>\n<td>([0-9NSWE\\°\\'\\′]*)</td>\n<td>(.*?)</td>\n<td>(.*?)</td>", Pattern.CASE_INSENSITIVE
					| Pattern.MULTILINE | Pattern.DOTALL);

	public static final Pattern patternCountry = Pattern.compile("<a.*>(.*?)</a>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);

	public static final Pattern patternCity = Pattern.compile("title=\\\"(.*?)\\\"", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);

	public static void main(String[] args) throws Exception {
		findCities(null);
	}

	public static void findCities(Set<Country> countries) throws Exception {

		HttpClient httpclient = new DefaultHttpClient();
		HttpGet httpget = new HttpGet("http://en.wikipedia.org/wiki/List_of_cities_by_latitude");
		HttpResponse response = httpclient.execute(httpget);
		HttpEntity entity = response.getEntity();

		List<City> cities = new ArrayList<City>();

		HashMap<String, String> countryNameMap = new HashMap<String, String>();
		countryNameMap.put("Greenland", "Norway");
		countryNameMap.put("People's Republic of China", "China, People's Republic of");
		countryNameMap.put("North Korea", "Korea, North");
		countryNameMap.put("Macedonia", "Macedonia, Republic of");
		countryNameMap.put("South Korea", "Korea, South");
		countryNameMap.put("Bahamas", "Bahamas, The");
		countryNameMap.put("Hong Kong, China", "Hong Kong");
		countryNameMap.put("Myanmar", "Burma");
		countryNameMap.put("Republic of China (Taiwan)", "Taiwan (Republic of China)");
		countryNameMap.put("Macau, China", "Macau");
		countryNameMap.put("Puerto Rico", "United States");
		countryNameMap.put("Gambia", "Gambia, The");
		countryNameMap.put("Republic of the Congo", "Congo, Republic of the");
		countryNameMap.put("Democratic Republic of the Congo", "Congo, Democratic Republic of the");
		countryNameMap.put("Timor-Leste", "East Timor");
		countryNameMap.put("Palestinian territories", "Palestine");

		if (entity != null) {
			String content = EntityUtils.toString(entity);

			Matcher m = patternEntry.matcher(content);
			System.out.println("matching...");
			while (m.find()) {
				String entryContent = m.group(1);
				Matcher m2 = patternPosition.matcher(entryContent);
				if (m2.find()) {

					City city = new City();

					city.setLatitude(convertToDegrees(m2.group(1)));

					city.setLongitude(convertToDegrees(m2.group(2)));

					String cityBulk = m2.group(3);
					Matcher m3 = patternCity.matcher(" " + cityBulk);
					if (m3.find()) {
						city.setName(m3.group(1));
					}

					String countryBulk = m2.group(4);
					Matcher m4 = patternCountry.matcher(countryBulk);
					if (m4.find()) {
						city.setCountry(m4.group(1));
					}

					cities.add(city);

					boolean countryFound = false;
					for (Country country : countries) {
						if (country.getSortName().equalsIgnoreCase(city.getCountry())) {
							country.getCities().add(city);
							countryFound = true;
							break;
						}
					}
					if (!countryFound && countryNameMap.keySet().contains(city.getCountry())) {
						for (Country country : countries) {
							if (country.getSortName().equalsIgnoreCase(countryNameMap.get(city.getCountry()))) {
								country.getCities().add(city);
								countryFound = true;
								break;
							}
						}
					}

					if (!countryFound) {
						System.out.println("Country " + city.getCountry() + " not found!");
					}

				}
			}

		}

		System.out.println("cities: " + cities.size());
	}

	public static BigDecimal convertToDegrees(String input) {

		input = input.replace('′', '\'');

		BigDecimal degree = new BigDecimal(input.substring(0, input.indexOf("°")));

		BigDecimal minute = new BigDecimal(input.substring(input.indexOf("°") + 1, input.indexOf("'")));

		BigDecimal returnValue = degree.add(minute.divide(new BigDecimal(60.0), 3, BigDecimal.ROUND_UP));

		String hr = input.substring(input.indexOf("'") + 1, input.indexOf("'") + 2);
		if ("S".equals(hr) || "W".equals(hr)) {
			returnValue = returnValue.multiply(new BigDecimal(-1));
		}

		return returnValue;
	}
}
