# 🛒 Zepto SQL Data Cleaning & Business Analysis

## 📌 Project Overview
This project analyzes **product listing data** from Zepto using SQL to:
- Clean and standardize raw data
- Identify pricing, discount, and stock patterns
- Generate actionable business insights

The dataset contains information about product names, categories, prices, discounts, availability, and weights.  
The analysis covers **data cleaning**, **exploration**, and **business insights**.

---

## 📂 Project Structure
Zepto_SQL_Analysis/
│
├── data/
│ └── Zepto_v2.csv # Raw dataset
│
├── scripts/
│ └── ZEPTO_V2_Cleaning_Analysis.sql # Full SQL cleaning + analysis
│
└── README.md # Documentation


---

## 🛠 Tools & Technologies
- **MySQL 8.0** – Data cleaning and analysis
- **SQL Workbench / DBeaver** – Query execution
- **GitHub** – Project sharing & version control

---

## 📊 Analysis Workflow

### **1. Data Cleaning**
- Removed NULL and zero-valued records in important fields
- Fixed encoding issues (BOM in column names)
- Corrected price values stored in paise instead of rupees
- Recalculated discount percentages
- Checked for inconsistent pricing (`DISCOUNTEDSELLINGPRICE > MRP`)

### **2. Data Exploration**
- Identified distinct product categories
- Counted in-stock vs out-of-stock products
- Detected duplicate product names

### **3. Business Insights**
- **Top discounted products** → Which products have the highest markdowns
- **Out-of-stock analysis** → Categories most often unavailable
- **High-value out-of-stock items** → Expensive items missing from inventory
- **Stockout risk prediction** → Based on quantity & discount level
- **Revenue estimation** → Total estimated revenue by category
- **Price per gram** → Value-for-money analysis for products > 100g
- **Weight categorization** → Small, medium, bulk product classification

---

## 📈 Key Insights
1. **High Discount → Low Stock**  
   Products with large discounts often have lower availability, suggesting strong demand.
2. **Certain Categories Dominate Revenue**  
   Some categories consistently bring in more revenue per unit.
3. **Premium Out-of-Stock Items**  
   Expensive products going out of stock represent missed sales opportunities.
4. **Discounts Likely Boost Turnover**  
   Categories with higher discounts tend to have fewer available units.

---

## 🚀 How to Use
1. **Import Dataset**  
   - Place `zepto_v2.csv` in MySQL database
   - Table name: `ZEPTO_V2`

2. **Run SQL Script**  
   - Execute queries in `ZEPTO_V2_Cleaning_Analysis.sql` step-by-step
   - Queries are grouped into:
     - Data Cleaning
     - Data Exploration
     - Business Insights

3. **Interpret Results**  
   - Use output tables to guide business decisions
   - Modify thresholds for stockout risk based on your needs

---

## 📌 Example Queries

### **Top 10 Discounted Products**
```sql
SELECT DISTINCT NAME, Category, MRP, DISCOUNTPERCENT
FROM ZEPTO_V2
ORDER BY DISCOUNTPERCENT DESC
LIMIT 10;
