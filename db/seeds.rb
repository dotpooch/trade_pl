Price.delete_all
Fill.delete_all
Transaction.delete_all
Trade.delete_all
FillDate.delete_all
Corporation.delete_all
Equity.delete_all
Profitability.delete_all
FillDate.make
Fill.make({:date =>'2001-05-29', :symbols =>["msft"], :price =>'71.22', :fill_type =>'1', :quantity =>'100', :commission =>'-14.95', :sec_fee =>'', :trade_stub =>'MSFT_3'})
Fill.make({:date =>'2001-06-14', :symbols =>["msft"], :price =>'69.16', :fill_type =>'6', :quantity =>'40', :commission =>'-7.45', :sec_fee =>'-1.16', :trade_stub =>'MSFT_3'})
Fill.make({:date =>'2001-06-14', :symbols =>["msft"], :price =>'69.21', :fill_type =>'6', :quantity =>'40', :commission =>'-7.50', :sec_fee =>'-1.16', :trade_stub =>'MSFT_3'})
Fill.make({:date =>'2001-06-14', :symbols =>["msft"], :price =>'69.83', :fill_type =>'6', :quantity =>'20', :commission =>'-14.95', :sec_fee =>'-2.33', :trade_stub =>'MSFT_3'})
Fill.make({:date =>'2001-06-28', :symbols =>["msft"], :price =>'72.26', :fill_type =>'2', :quantity =>'50', :commission =>'-1.48', :sec_fee =>'-0.49', :trade_stub =>'MSFT_5'})
Fill.make({:date =>'2001-06-28', :symbols =>["msft"], :price =>'72.50', :fill_type =>'6', :quantity =>'60', :commission =>'-1.63', :sec_fee =>'-0.49', :trade_stub =>'MSFT_4'})
Fill.make({:date =>'2001-06-28', :symbols =>["msft"], :price =>'72.54', :fill_type =>'7', :quantity =>'100', :commission =>'-1.48', :sec_fee =>'', :trade_stub =>'MSFT_5'})
Fill.make({:date =>'2001-06-28', :symbols =>["msft"], :price =>'72.26', :fill_type =>'6', :quantity =>'40', :commission =>'-13.32', :sec_fee =>'-4.34', :trade_stub =>'MSFT_4'})
Fill.make({:date =>'2001-06-28', :symbols =>["msft"], :price =>'72.27', :fill_type =>'2', :quantity =>'50', :commission =>'-13.47', :sec_fee =>'-4.34', :trade_stub =>'MSFT_5'})
Fill.make({:date =>'2001-06-28', :symbols =>["msft"], :price =>'73.29', :fill_type =>'1', :quantity =>'100', :commission =>'-14.95', :sec_fee =>'', :trade_stub =>'MSFT_4'})
Fill.make({:date =>'2002-10-24', :symbols =>["ibm"]	, :price =>'72.50', :fill_type =>'2', :quantity =>'20', :commission =>'-11.21', :sec_fee =>'', :trade_stub =>'IBM_1'})
Fill.make({:date =>'2002-10-29', :symbols =>["ibm"], :price =>'74.31',:fill_type =>'2', :quantity =>'20', :commission =>'-0.23', :sec_fee =>'', :trade_stub =>'IBM_1'})
Fill.make({:date =>'2002-10-29', :symbols =>["ibm"], :price =>'74.31',:fill_type =>'2', :quantity =>'20', :commission =>'-0.23', :sec_fee =>'', :trade_stub =>'IBM_1'})
Fill.make({:date =>'2002-10-29', :symbols =>["ibm"], :price =>'74.33',:fill_type =>'2', :quantity =>'40', :commission =>'-12.78', :sec_fee =>'', :trade_stub =>'IBM_1'})
Fill.make({:date =>'2002-10-29', :symbols =>["ibm"], :price =>'75.98',:fill_type =>'7', :quantity =>'100', :commission =>'-10.99', :sec_fee =>'', :trade_stub =>'IBM_1'})
Fill.make({:date =>'2002-11-06', :symbols =>["ibm"], :price =>'81.44',:fill_type =>'7', :quantity =>'50', :commission =>'', :sec_fee =>'', :trade_stub =>'IBM_2'})
Fill.make({:date =>'2002-11-06', :symbols =>["ibm"], :price =>'80.09',:fill_type =>'2', :quantity =>'50', :commission =>'-12.20', :sec_fee =>'', :trade_stub =>'IBM_2'})
Fill.make({:date =>'2002-11-06', :symbols =>["ibm"], :price =>'80.77',:fill_type =>'2', :quantity =>'50', :commission =>'-12.21', :sec_fee =>'', :trade_stub =>'IBM_2'})
Fill.make({:date =>'2002-11-06', :symbols =>["ibm"], :price =>'81.40',:fill_type =>'7', :quantity =>'50', :commission =>'-10.99', :sec_fee =>'', :trade_stub =>'IBM_2'})
Fill.make({:date =>'2002-12-02', :symbols =>["ibm"], :price =>'88.95',:fill_type =>'2', :quantity =>'100', :commission =>'-11.26', :sec_fee =>'', :trade_stub =>'IBM_4'})
Fill.make({:date =>'2002-12-16', :symbols =>["ibm"], :price =>'80.45',:fill_type =>'7', :quantity =>'100', :commission =>'-10.99', :sec_fee =>'', :trade_stub =>'IBM_4'})
Fill.make({:date =>'2005-03-23', :symbols =>["aapl"], :names =>["Apple Computer, Inc."], :price =>'42.77', :fill_type =>'2', :quantity =>'100', :commission =>'-12.40', :sec_fee =>'', :trade_stub =>'AAPL_1'})
Fill.make({:date =>'2005-04-06', :symbols =>["aapl"], :names =>["Apple Computer, Inc."], :price =>'42.49', :fill_type =>'7', :quantity =>'100', :commission =>'-10.99', :sec_fee =>'', :trade_stub =>'AAPL_1'})
Fill.make({:date =>'2007-01-12', :symbols =>["aapl"], :names =>["Apple Computer, Inc."], :price =>'91.63', :fill_type =>'1', :quantity =>'50', :commission =>'', :sec_fee =>'', :trade_stub =>'AAPL_3'})
Fill.make({:date =>'2007-01-12', :symbols =>["aapl"], :names =>["Apple Computer, Inc."], :price =>'91.62', :fill_type =>'1', :quantity =>'50', :commission =>'-9.99', :sec_fee =>'', :trade_stub =>'AAPL_3'})
Fill.make({:date =>'2008-03-04', :symbols =>["aapl"], :names =>["Apple Computer, Inc."], :price =>'120.71', :fill_type =>'6', :quantity =>'100', :commission =>'-9.99', :sec_fee =>'-0.40', :trade_stub =>'AAPL_3'})
Fill.make({:date =>'2008-03-04', :symbols =>["aapl"], :names =>["Apple Computer, Inc."], :price =>'123.87', :fill_type =>'1', :quantity =>'50', :commission =>'-9.99', :sec_fee =>'', :trade_stub =>'AAPL_7'})
Fill.make({:date =>'2008-03-05', :symbols =>["aapl"], :names =>["Apple Computer, Inc."], :price =>'124.46', :fill_type =>'1', :quantity =>'50', :commission =>'-9.99', :sec_fee =>'', :trade_stub =>'AAPL_7'})
Fill.make({:date =>'2008-09-16', :symbols =>["aapl"], :names =>["Apple Computer, Inc."], :price =>'142', :fill_type =>'6', :quantity =>'100', :commission =>'-9.99', :sec_fee =>'-0.24', :trade_stub =>'AAPL_7'})
Fill.name_fills_trades_transactions
Security.updated(true)
Trade.assemble
Transaction.assemble
FillDate.assemble_joins
Profitability.query_trades
Security.updated