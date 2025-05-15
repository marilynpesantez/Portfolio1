# Project Background
The Online Retail II dataset comes from a UK-based, non-store online retailer specializing in unique all-occasion gift-ware. 

This data contains transactional records running from December 1, 2009, to December 9, 2011. The business relied heavily on e-commerce, with a substantial portion of the sales within this frame being driven by wholesalers. This project analyzes the company's retail performance over a two-year time span to derive actionalable insights. This project addresses/analyze sales trends, evaluates product performance, and uncover areas where business strategies can be enhanced. --> to uncover untapped potential for promotion bundles, untapped markets, and inventory/logistical improvements to accomodate for holiday.

Insights and recommendations are provided on the following key areas:

- **Sales Trend Analysis:** An evaluation of historical sales patterns, identifying seasonal and monthly trends with a focus Sales Revenue, Order Volume, and Average Order Value (AOV).
- **Product Perfromance Evaluation:** Given the extensive variety of products sold, this assestment looks into the performance of individual top performing products, assessing sales volume and revenue generation. Insights will be used to suggest potential product optimization strategies or inventory adjustments.
- **Regional Sales Comparison:** This analysis will examine sales across different countries to identify geographic performance differences. By understanding which regions are performing best and where improvements can be made, the company can tailor marketing efforts and regional strategies more effectively.

The SQL queries used to inspect and clean the data for this analysis can be found here [link].

Targed SQL queries regarding various business questions can be found here [link].

An interactive Tableau dashboard used to report and explore sales trends can be found here [link].


# Data Structure & Initial Checks

The companies main database structure as seen below consists of one table broken out into 4 unique views with a total row count of 1067371 records. A description of each view is as follows:
- **sale_view:** All records where Quantity is greater than zero, UnitPrice is greater than zero, and StockCode does not equal 'B' are assumed to represent sales transactions.
- **giveaway_view:** All records where where Quantity is greater than zero, UnitPrice equals 0, CustomerID is not empty, and Item is not empty are assumed to represent items given away to customers for free through special promotions or bundles.
- **cancellation_view:** All records where Quantity is less than zero and InvoiceNo begins with 'C' are assumed to represent cancelled transactions. Cancellation patterns are acknowledged in the analysis but not included in sales_view as they distort Order Volume and Average Order Value metrics.
- **test_view:** All records where UnitPrice equals 0 and CustomerID is empty are assumed to be system tests that do not represent any tangible transactions.
- **bad_debt_adjustment:** All records where where InvoiceNo begins with 'A' and StockCode equals 'B'.
- **duplicated_rows_view:** All records where each column value is exactly equal to the values in some other row. A Row_Number() function was applied to the original raw view, partitioning over each column. This was done to identify duplicate records (where row_num > 1) and differenciate between the original record (where row_num = 1). These duplicates were labeled and excluded from the sale_view.

![image](https://github.com/user-attachments/assets/92a847b5-4b3d-4e24-ba9f-6732c0ff1088)

![image](https://github.com/user-attachments/assets/86cbb4a1-4a43-4485-8bc1-de0edc1867a0)




# Executive Summary

### Overview of Findings

Explain the overarching findings, trends, and themes in 2-3 sentences here. This section should address the question: "If a stakeholder were to take away 3 main insights from your project, what are the most important things they should know?" You can put yourself in the shoes of a specific stakeholder - for example, a marketing manager or finance director - to think creatively about this section.

[Visualization, including a graph of overall trends or snapshot of a dashboard]



# Insights Deep Dive
### Sales Trends:

* **The company's sales figures peaked in November 2011 with 2,770 orders totaling $1,503,866.78 in monthly revenue.** This aligns with a universal peak in retail shopping and gift purchases leading up to the end-of-year holidays.
  
* **Sales revenue and order volume dipped in December following holiday season booms in both 2010 and 2011.** Revenue declined for three consecutive months starting in December 2010, dropping to its lowest point in February 2011 with $522,545.56 in revenue. Order volume followed a similar trend, dipping in December 2010 and hitting a low in February 2011 before recovering the following month. 
  
* **Revenue and order volume recover in March, staggering through the summer months.**
  
* **While average order value peaked in December 2011, there was also a peak in average order value of cancelled transactions.** The peak in cancelled order volume during this same month may correspond with wholesaler customers overanticipating demand for their own respective shops and cancelled their orders through this wholesaler.

![image](https://github.com/user-attachments/assets/68f73b80-a713-49c3-bd8e-b92633b9389d)


### Regional Trends:

* **United Kingdom dominates in sales revenue and order volume, signaling the company's robust market presence in the region** This may be reflective of the UK's large customer base and strong demand for gift-ware products, as well as logistical efficiencies in buying from a UK-based wholesaler. While the market is large and order volume is high, the relatively lower AOV in comparison to other regions indicates that a larger volume of lower-value orders is driving overall sales for the region. With the UK holding a top position, increasing AOV in this key market should be a key focus.
  
* **Strong performers in Western Europe (Germany, EIRE, France, and Netherlands), reflecting wides** High sales revenue in these regions is supported by morderate-to-high order volumes and AOV, indicating a mix of both frequenty and high-value transactions across these countries. Customer retention should be a key focus. 
  
* **EIRE ranks second in total sales revenue after UK, but has a higher AOV than the UK.** A high AOV in EIRE indicates a more wholesale-focused customer base that is willing to make larger purchases. While customers in Ireland are spending more per transaction on average, overall order volume is lower than in the UK. Customer base size acts as greater limiting factor on order volume in EIRE compared to the UK. Driving purchase frequency should be a key focus.


[Visualization specific to category 3]



# Recommendations:

Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following: 

* Sales revenue and order volume experience month-over-month growth from August to November, signaling a holiday seasonality effect from a higher universal demand for gift-ware. **The company should double down on promotions, discounts, and advertising spend during November and December to take advantage of these seasonality effects. Further inventory planning should be carried out to meet demand, particularly for items that have sold out in the past.**
  
* AOV dips from January to March. **The business should offer post-holiday promotions to boost order volume and sales. reach existing customers using a re-engagement email campaign to offer special discounts, pull customers back in, and drive order value. The business should implement a targeted upsell strategy through pricing and bundling strategies to reward and encourage high-value purchass.**
  
* Sales revenue and order volume recover in March, fluctuating through to August. **The business should consider running targeted summer campaigns catered to major holidays or events celebrated in each respective region. The retailer can drive order volume by tapping into these unique "ocassions" and celebrations for regions that already have a moderate-to-high AOV.**
  
* High Sales and Order Volume in the UK. **Consider offering discounts on larger orders or creating bundled packages. This could boost average order value and contribute to substantial revenue growth.**
  
* Moderate-to-high AOV in Western Europe, suggesting customers are willing to spend more on each transaction. **To capitalize on this and drive order volume, considering implementing loyalty programs, as well as expanding product selection or even renaming product lines & categories throughout the year. This will position the retailer as a distination for more than just giftware, while incentivizing existing whilesale customers to increase their purchase frequency.**

* With the reatiler being positioned as a giftware destination, a big chunk of sales revenue is dependent on end-of-year holiday success. **The company would  benefit from establishing relationships through targeted acquisition strategies with wholesale customers that carry a broader range of products and are more likely to the make bulk purchases throughout the year. This is dependent on expanding product selection or crosslisting products under different "buckets" to improve the discoverability of versatile "giftware" items.**

* Low Sales and Order Volume in Saudi Arabia, Brazil, and Nigeria. **Consider investing in localized marketing campaigns that cater to local customs and holidays. Explore relationships with local wholesalers to increase visibility and tap into these emerging markets.**

# Assumptions and Caveats:

Throughout the analysis, multiple assumptions were made to manage challenges with the data. These assumptions and caveats are noted below:

* Assumption 1 (ex: records where InvoiceNo began with 'A' and "StockCode' equaled 'B' were assumed to be bad debt adjustments, these were excluded from the analysis).
  
* Assumption 2 (ex: records where where Quantity is greater than zero and UnitPrice equals 0 did not contribute to sales revenue, these were excluded from the analysis). 
