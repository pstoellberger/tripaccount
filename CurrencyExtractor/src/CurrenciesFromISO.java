import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

public class CurrenciesFromISO {

	public static final Pattern patternEntry = Pattern.compile("<tr>(.*?)</tr>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
	public static final Pattern patternIsoCode = Pattern.compile("<td>([A-Z]*)</td>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
	public static final Pattern patternName = Pattern.compile("<td><a href=.*?>(.*?)</a>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE
			| Pattern.DOTALL);
	public static final Pattern patternDigits = Pattern.compile("<td>(\\d)</td>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);

	public static final Pattern patternCountry = Pattern.compile("<td><span class=\"flagicon\">(.*?)</td>", Pattern.CASE_INSENSITIVE
			| Pattern.MULTILINE | Pattern.DOTALL);
	public static final Pattern patternCountryImage = Pattern.compile("src=\"(.*?)\"", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
	public static final Pattern patternCountryName = Pattern.compile("<a .*?>(.*?)</a>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE
			| Pattern.DOTALL);

	public static List<Currency> getCurrenciesFromISO() throws Exception {

		HttpClient httpclient = new DefaultHttpClient();
		HttpGet httpget = new HttpGet("http://en.wikipedia.org/wiki/ISO_4217");
		HttpResponse response = httpclient.execute(httpget);
		HttpEntity entity = response.getEntity();

		List<Currency> currencies = new ArrayList<Currency>();

		if (entity != null) {
			String content = EntityUtils.toString(entity);
			// content = content.replaceAll("\n", "");

			Matcher m = patternEntry.matcher(content);
			System.out.println("matching...");
			while (m.find()) {
				String entryContent = m.group(1);
				Matcher m2 = patternIsoCode.matcher(entryContent);
				if (m2.find()) {
					Currency c = new Currency();
					currencies.add(c);

					c.setIsoCode(m2.group(1));

					Matcher m3 = patternName.matcher(entryContent);
					if (m3.find()) {
						c.setName(m3.group(1));
					}

					Matcher m4 = patternDigits.matcher(entryContent);
					if (m4.find()) {
						c.setNumberOfDigitsAfterSep(Integer.valueOf(m4.group(1)));
					}

					Matcher m5 = patternCountry.matcher(entryContent);
					if (m5.find()) {
						String countryContent = m5.group(1);

						Matcher m6 = patternCountryName.matcher(countryContent);
						while (m6.find()) {
							Country country = new Country();
							country.setName(m6.group(1));
							c.getCountries().add(country);
						}

						m6 = patternCountryImage.matcher(countryContent);
						int counter = 0;
						while (m6.find()) {
							c.getCountries().get(counter).setImgPath(new URL(m6.group(1)));
							counter++;
						}
					}
				}
			}
		}

		Iterator<Currency> iterator = currencies.iterator();
		while (iterator.hasNext()) {
			Currency currency = iterator.next();
			if (currency.getName() == null || "WIR".equals(currency.getName()) || currency.getCountries().size() == 0) {
				iterator.remove();
			}
		}

		return currencies;
	}

}
