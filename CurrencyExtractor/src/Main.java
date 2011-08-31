import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

public class Main {

	public static final Pattern patternEntry = Pattern.compile("(<tr>.*?</tr>)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);

	public static final Pattern patternIsoCode = Pattern
			.compile("<td>([A-Z]{3})</td>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);

	public static final Pattern patternName = Pattern.compile("<td><a href=.*?>(.*?)</a>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE
			| Pattern.DOTALL);

	public static final Pattern patternCountry = Pattern.compile("<td.*?>.*?<span class=\"flagicon\">(.*?)</td>", Pattern.CASE_INSENSITIVE
			| Pattern.MULTILINE | Pattern.DOTALL);
	public static final Pattern patternCountryImage = Pattern.compile("src=\"(.*?)\"", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
	public static final Pattern patternCountryName = Pattern.compile("<a .*?>(.*?)</a>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE
			| Pattern.DOTALL);

	public static void main(String[] args) throws Exception {

		HttpClient httpclient = new DefaultHttpClient();
		HttpGet httpget = new HttpGet("http://en.wikipedia.org/wiki/List_of_circulating_currencies");
		HttpResponse response = httpclient.execute(httpget);
		HttpEntity entity = response.getEntity();

		List<Currency> currencies = new ArrayList<Currency>();

		Set<Country> countries = new TreeSet<Country>();

		if (entity != null) {
			String content = EntityUtils.toString(entity);
			// content = content.replaceAll("\n", "");

			Country country = null;

			Matcher m = patternEntry.matcher(content);
			System.out.println("matching...");
			while (m.find()) {
				String entryContent = m.group(1);

				Matcher mCountry = patternCountry.matcher(entryContent);
				if (mCountry.find()) {
					country = new Country();
					countries.add(country);

					String countryContent = mCountry.group(1);

					Matcher m6 = patternCountryName.matcher(countryContent);
					while (m6.find()) {
						country.setSortName(m6.group(1));
					}

					if (country.getSortName() != null && country.getSortName().contains(",")) {
						country.setName(country.getSortName().substring(country.getSortName().indexOf(",") + 1) + " "
								+ country.getSortName().substring(0, country.getSortName().indexOf(",")));
					} else {
						country.setName(country.getSortName());
					}

					m6 = patternCountryImage.matcher(countryContent);
					if (m6.find()) {
						country.setImgPath(new URL(m6.group(1)));
					}
				}

				Matcher m2 = patternIsoCode.matcher(entryContent);
				if (m2.find()) {
					Currency c = new Currency();
					c.setIsoCode(m2.group(1));

					if (currencies.contains(c)) {
						c = currencies.get(currencies.indexOf(c));
					} else {
						currencies.add(c);
						Matcher m3 = patternName.matcher(entryContent);
						if (m3.find()) {
							c.setName(m3.group(1));
						}
					}
					c.getCountries().add(country);
				}
			}
		}

		Iterator<Currency> iterator = currencies.iterator();
		while (iterator.hasNext()) {
			Currency currency = iterator.next();
			if (currency.getName() == null || "WIR".equals(currency.getName()) || currency.getCountries().size() == 0) {
				// iterator.remove();
			}
		}

		List<Currency> iso = CurrenciesFromISO.getCurrenciesFromISO();
		for (Currency isoCurrency : iso) {
			if (currencies.contains(isoCurrency)) {
				currencies.get(currencies.indexOf(isoCurrency)).setNumberOfDigitsAfterSep(isoCurrency.getNumberOfDigitsAfterSep());
			}
		}

		for (Currency currency : currencies) {
			System.out.println(currency);
		}
		System.out.println(currencies.size());

		getExchangeRates(currencies, "EUR");
		getExchangeRates(currencies, "USD");

		writeFlags(currencies, countries, new File("/tmp/currencyOutput"));

		// translate currencies
		BufferedReader reader = new BufferedReader(new InputStreamReader(Main.class.getResourceAsStream("currencies_de.txt")));
		String line;
		while ((line = reader.readLine()) != null) {
			StringTokenizer tokenizer = new StringTokenizer(line, "\t");
			if (tokenizer.hasMoreTokens()) {
				String nameDe = tokenizer.nextToken();
				String code = tokenizer.nextToken();

				for (Currency currency : currencies) {
					if (currency.getIsoCode().toUpperCase().equals(code)) {
						currency.setNameDe(nameDe);
						break;
					}
				}
			}
		}

		for (Currency currency : currencies) {
			if (currency.getNameDe() == null) {
				System.out.println("Currency " + currency.getName() + " " + currency.getIsoCode() + " has no DE name");
			}
		}

		// translate countries
		reader = new BufferedReader(new InputStreamReader(Main.class.getResourceAsStream("countries_de.txt")));
		while ((line = reader.readLine()) != null) {
			StringTokenizer tokenizer = new StringTokenizer(line, "\t");
			if (tokenizer.hasMoreTokens()) {
				String name = tokenizer.nextToken();
				String nameDe = tokenizer.nextToken();

				for (Country country : countries) {
					if (country.getName().equalsIgnoreCase(name)) {
						country.setNameDe(nameDe);
						break;
					}
				}
			}
		}

		for (Country country : countries) {
			if (country.getNameDe() == null) {
				System.out.println("Country " + country.getName() + " has no DE name");
			}
		}

		CityExtractor.findCities(countries);

		// FileWriter writer = new FileWriter(new File("/Users/tine2k/countryList.txt"));
		// for (Country country : countries) {
		// if (country.getNameDe() == null) {
		// writer.write(country.getName() + "\n");
		// }
		// }
		// writer.close();

		for (Country country : countries) {
			if (country.getName().startsWith("The ")) {
				country.setName(country.getName().substring("The ".length()));
			}
		}

		writeOut(currencies, new File("/tmp/currencyOutput"));
	}

	private static void getExchangeRates(List<Currency> currencies, String baseCurrencyIsoCode) throws Exception {

		System.out.println("Getting exchange rates with base currency " + baseCurrencyIsoCode);

		StringBuffer buffer = new StringBuffer();
		for (Currency currency : currencies) {
			buffer.append(baseCurrencyIsoCode + currency.getIsoCode() + "=X+");
		}

		HttpClient httpclient = new DefaultHttpClient();
		HttpGet httpget = new HttpGet("http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=" + buffer.toString());
		HttpResponse response = httpclient.execute(httpget);
		HttpEntity entity = response.getEntity();

		BufferedReader reader = new BufferedReader(new InputStreamReader(entity.getContent()));
		String line = null;
		while ((line = reader.readLine()) != null) {
			StringTokenizer tokenizer = new StringTokenizer(line, ",");
			if (tokenizer.countTokens() != 4) {
				System.out.println("Invalid number of tokens.");
				continue;
			}

			ExchangeRate rate = new ExchangeRate();

			try {
				String currencyToken = tokenizer.nextToken();

				String baseCurrencyStr = currencyToken.substring(1, 4);
				String counterCurrencyStr = currencyToken.substring(4, 7);

				Currency counterCurrency = getCurrencyFromList(currencies, counterCurrencyStr);
				rate.setBaseCurrency(getCurrencyFromList(currencies, baseCurrencyStr));

				String rateToken = tokenizer.nextToken();
				rate.setExchangeRate(Double.parseDouble(rateToken));

				String dateToken = tokenizer.nextToken() + tokenizer.nextToken();
				SimpleDateFormat sdf = new SimpleDateFormat("\"MM/dd/yyyy\"\"KK:mma\"");

				rate.setExchangeRateUpdated(sdf.parse(dateToken));

				counterCurrency.getRates().add(rate);
			} catch (Exception e) {
				System.out.println("Error processing line: " + line);
			}
		}
	}

	public static Currency getCurrencyFromList(List<Currency> currencies, String isoCode) {
		for (Currency currency : currencies) {
			if (currency.getIsoCode().equals(isoCode)) {
				return currency;
			}
		}
		return null;
	}

	private static void writeFlags(List<Currency> currencies, Set<Country> countries, File directory) throws Exception {

		if (!directory.exists()) {
			directory.mkdirs();
		}

		Collections.sort(currencies);

		int counter = 0;
		for (Country country : countries) {
			counter++;
			country.setId(counter);
		}

		int flagFound = 0;

		boolean skipFlags = false;
		if (skipFlags) {
			System.out.println("Ignoring flags (this time). ");
		} else {
			for (Country country : countries) {

				country.setImgPath(null);
				File f = new File("bubbles");
				for (File file : f.listFiles()) {

					List<String> countryNames = new ArrayList<String>();
					countryNames.add(country.getSortName());
					countryNames.add(country.getSortName().toLowerCase().replace(",", "").replace(" the", "").replace("-", " "));

					String fileNameToCompare = file.getName().substring(0, file.getName().length() - ".png".length()).replace("_", " ");
					for (String countryName : countryNames) {
						if (fileNameToCompare.equalsIgnoreCase(countryName.trim())) {
							country.setImgPath(file.toURI().toURL());
							flagFound++;
							FileUtils.copyFile(file, new File(directory, country.getImgName()));
							break;
						}
					}
				}

				// HttpClient httpclient = new DefaultHttpClient();
				// HttpGet httpget = new HttpGet(country.getImgPath().toExternalForm().replace("22px", "200px"));
				// HttpResponse response = httpclient.execute(httpget);
				// HttpEntity entity = response.getEntity();
				//
				// InputStream in = entity.getContent();
				// FileOutputStream out = new FileOutputStream(new File(directory, country.getImgName()));
				// int c;
				// while ((c = in.read()) >= 0) {
				// out.write(c);
				// }
				// out.close();
				// in.close();
			}
		}

		System.out.println("Countries = " + countries.size());
		System.out.println("Flags = " + flagFound);

		System.out.println("No flag for ");
		for (Country country : countries) {
			if (country.getImgPath() == null) {
				System.out.println(country.getSortName());
				for (Currency cur : currencies) {
					if (cur.getCountries().contains(country)) {
						System.out.println("  - " + cur.getName());
					}
				}
			}
		}

		int currenciesWithoutCountry = 0;
		for (Currency currency : currencies) {
			if (currency.getCountries().size() == 0) {
				currenciesWithoutCountry++;
			}
		}
		System.out.println("currenciesWithoutCountry: " + currenciesWithoutCountry);

		List<String> countryExceptions = new ArrayList<String>(); // Arrays.asList("Montenegro", "Israel", "Congo, Republic of the", "Kosovo",
																	// "Libya");

		Iterator<Currency> curIter = currencies.iterator();
		while (curIter.hasNext()) {
			Currency currency = curIter.next();
			Iterator<Country> counIter = currency.getCountries().iterator();
			while (counIter.hasNext()) {
				Country country = counIter.next();
				if (country.getImgPath() == null) {
					if (!countryExceptions.contains(country.getName())) {
						System.out.println("Removing country " + country.getSortName());
						countries.remove(country);
						counIter.remove();
					}
				}
			}
		}

		currenciesWithoutCountry = 0;
		for (Currency currency : currencies) {
			if (currency.getCountries().size() == 0) {
				currenciesWithoutCountry++;
			}
		}
		System.out.println("currenciesWithoutCountry: " + currenciesWithoutCountry);

		curIter = currencies.iterator();
		while (curIter.hasNext()) {
			Currency currency = curIter.next();
			if (currency.getCountries().size() == 0) {
				curIter.remove();
			}
		}
	}

	private static void writeOut(List<Currency> currencies, File directory) throws Exception {

		Set<Country> countries = new TreeSet<Country>();
		for (Currency currency : currencies) {
			countries.addAll(currency.getCountries());
		}

		boolean skipPlists = false;
		if (skipPlists) {
			System.out.println("Ignoring PList files (this time). ");
		} else {
			OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(new File(directory, "countries.plist")), "UTF-8");
			write(writer, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
			write(writer, "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">");
			write(writer, "<plist version=\"1.0\">");
			write(writer, "<dict>");
			write(writer, "<key>countries</key>");
			write(writer, "<array>");
			for (Country country : countries) {
				write(writer, "<dict>");
				write(writer, "<key>name</key>");
				write(writer, "<string>" + country.getName() + "</string>");
				write(writer, "<key>name_de</key>");
				write(writer, "<string>" + country.getNameDe() + "</string>");
				write(writer, "<key>sortName</key>");
				write(writer, "<string>" + country.getSortName() + "</string>");
				write(writer, "<key>id</key>");
				write(writer, "<integer>" + country.getId() + "</integer>");
				write(writer, "<key>image</key>");
				write(writer, "<string>" + country.getImgName() + "</string>");
				write(writer, "<key>cities</key>");
				write(writer, "<array>");
				for (City city : country.getCities()) {
					write(writer, "<dict>");
					write(writer, "<key>name</key>");
					write(writer, "<string>" + city.getName() + "</string>");
					write(writer, "<key>longitude</key>");
					write(writer, "<real>" + city.getLongitude() + "</real>");
					write(writer, "<key>latitude</key>");
					write(writer, "<real>" + city.getLatitude() + "</real>");
					write(writer, "</dict>");
				}
				write(writer, "</array>");
				write(writer, "</dict>");
			}
			write(writer, "</array>");

			write(writer, "</dict>");
			write(writer, "</plist>");
			writer.close();

			writer = new OutputStreamWriter(new FileOutputStream(new File(directory, "currencies.plist")), "UTF-8");
			write(writer, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
			write(writer, "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">");
			write(writer, "<plist version=\"1.0\">");
			write(writer, "<dict>");
			write(writer, "<key>currencies</key>");
			write(writer, "<array>");
			for (Currency currency : currencies) {
				write(writer, "<dict>");
				write(writer, "<key>code</key>");
				write(writer, "<string>" + currency.getIsoCode() + "</string>");
				write(writer, "<key>name</key>");
				write(writer, "<string>" + currency.getName() + "</string>");
				write(writer, "<key>name_de</key>");
				write(writer, "<string>" + currency.getNameDe() + "</string>");
				write(writer, "<key>digits</key>");
				write(writer, "<integer>" + currency.getNumberOfDigitsAfterSep() + "</integer>");
				write(writer, "<key>rates</key>");
				write(writer, "<dict>");
				for (ExchangeRate rate : currency.getRates()) {
					write(writer, "<key>" + rate.getBaseCurrency().getIsoCode() + "</key>");
					write(writer, "<real>" + rate.getExchangeRate() + "</real>");
				}
				write(writer, "</dict>");
				write(writer, "<key>countries</key>");
				write(writer, "<array>");
				for (Country country : currency.getCountries()) {
					write(writer, "<integer>" + country.getId() + "</integer>");
				}
				write(writer, "</array>");
				write(writer, "</dict>");
			}
			write(writer, "</array>");

			write(writer, "<key>lastUpdated</key>");
			write(writer, "<date>" + new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(new Date()) + "</date>");
			write(writer, "</dict>");
			write(writer, "</plist>");
			writer.close();
		}
	}

	public static void write(OutputStreamWriter writer, String content) throws Exception {
		writer.write(content + "\n");
	}
}
