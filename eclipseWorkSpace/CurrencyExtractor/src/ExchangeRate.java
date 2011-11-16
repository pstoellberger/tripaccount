import java.util.Date;

public class ExchangeRate {

	private Currency baseCurrency;
	private double exchangeRate;
	private Date exchangeRateUpdated;

	public Currency getBaseCurrency() {
		return baseCurrency;
	}

	public void setBaseCurrency(Currency baseCurrency) {
		this.baseCurrency = baseCurrency;
	}

	public double getExchangeRate() {
		return exchangeRate;
	}

	public void setExchangeRate(double exchangeRate) {
		this.exchangeRate = exchangeRate;
	}

	public Date getExchangeRateUpdated() {
		return exchangeRateUpdated;
	}

	public void setExchangeRateUpdated(Date exchangeRateUpdated) {
		this.exchangeRateUpdated = exchangeRateUpdated;
	}

}
