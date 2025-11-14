CREATE TABLE reliance_stock_data(
	stock_date date,
	stock_price float,
	stock_open float,
	stock_high float,
	stock_low float,
	stock_volume float,
	stock_change float
);


select * from reliance_stock_data;

-- 3. Add columns for 7-day moving average and 7-day volatility of stock_price/daily returns
ALTER TABLE reliance_stock_data ADD COLUMN MA_7 FLOAT;
ALTER TABLE reliance_stock_data ADD COLUMN Volatility_7 FLOAT;

-- 4. Calculate 7-day moving average of stock_price
UPDATE reliance_stock_data r1
JOIN (
  SELECT stock_date, AVG(stock_price) OVER (ORDER BY stock_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ma7
  FROM reliance_stock_data
) r2 ON r1.stock_date = r2.stock_date
SET r1.MA_7 = r2.ma7;

-- 5. Calculate daily returns (percentage change of stock_price)
ALTER TABLE reliance_stock_data ADD COLUMN daily_return FLOAT;

UPDATE reliance_stock_data r1
JOIN reliance_stock_data r2
  ON r1.stock_date = DATE_ADD(r2.stock_date, INTERVAL 1 DAY)
SET r1.daily_return = ((r1.stock_price - r2.stock_price) / r2.stock_price) * 100;

-- 6. Calculate 7-day volatility (stddev) of daily_return
UPDATE reliance_stock_data r1
JOIN (
  SELECT stock_date, STDDEV_SAMP(daily_return) OVER (ORDER BY stock_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS vol7
  FROM reliance_stock_data
) r2 ON r1.stock_date = r2.stock_date
SET r1.Volatility_7 = r2.vol7;


select * from reliance_stock_data;