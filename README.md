# 📊 Retail Sales Data Analysis Project (End-to-End Pipeline)

An end-to-end data analysis project simulating a real-world retail/e-commerce business workflow. This project covers everything from data storage and cleaning to deep analytical insights and interactive dashboard creation using **Excel, SQL, Python, and Power BI**.

---

## 📁 Repository Structure & File Directory

Here is how the project files are organized in this repository:

*   **`data/`** : Contains the raw datasets (`sales_data.csv`, `customers.csv`, `products.csv`, `stores.csv`, `inventory.csv`) used for the entire analysis.
*   **`master.xlsx`** : The final Excel workbook featuring data cleaning, formulas (VLOOKUP/INDEX-MATCH), Pivot Tables, and a beginner-level operational dashboard.
*   **`sales.sql`** : SQL script containing database schemas, table creation commands, relationships, and advanced analytical queries (Joins, Window Functions, Views).
*   **`retail_analysis.ipynb`** : Jupyter Notebook containing the complete Python data pipeline (Pandas cleaning, EDA, RFM Customer Segmentation, and Predictive Modeling).
*   **`sales_data.pbix`** : The main Power BI Desktop file with a fully interactive 3-page Executive Dashboard (Overview, Store Analysis, Product Performance).
*   **`Complete_Setup_Guide.docx`** : Detailed documentation covering step-by-step installation and workflow setup.
*   **`Practice_Questions.docx`** : A structured set of business questions across all tools used to guide the analysis.

---

## 🛠️ Tech Stack & Project Workflow

The project follows a standard structured data pipeline using four essential data analytics tools:

1.  **Data Storage & Extraction (SQL):** Built a relational database schema (Star Schema), imported CSV data, and ran complex queries to extract cleaned datasets.
2.  **Exploratory Data Analysis & Advanced Analytics (Python):** Merged dataframes using Pandas, engineered new date features, performed RFM Analysis for customer segmentation, and applied Linear Regression/K-Means Clustering.
3.  **Quick Reporting & Auditing (Excel):** Used VLOOKUP and dynamic tables for immediate data checks, created pivot tables, and built an operational dashboard.
4.  **Business Intelligence & Data Visualization (Power BI):** Modeled data into a Star Schema, built robust DAX measures (Time Intelligence for MoM/YoY growth), and created an executive-ready multi-page report.

---

## 🚀 Key Business Insights Discovered

*   **Top Performing Categories:** Analyzed revenue generation across product categories to pinpoint high-margin items.
*   **Customer Segmentation (RFM):** Classed customers into Champions, Loyal, At-Risk, and Lost categories to optimize targeted marketing strategies.
*   **Sales Trends:** Identified peak purchasing months and growth patterns using Month-over-Month (MoM) and Year-over-Year (YoY) revenue comparison metrics.
*   **Store & Regional Performance:** Mapped city-wise sales performance to identify underperforming regions and stock reorder requirements.

---

## 🔧 How to Run This Project

1.  **Database Setup:** Run the scripts inside `sales.sql` in your MySQL Workbench / SQLite database to create tables and import the CSV files from the `data/` folder.
2.  **Python Notebook:** Install dependencies (`pip install pandas matplotlib seaborn scikit-learn`) and run `retail_analysis.ipynb` inside Jupyter Notebook or VS Code.
3.  **Power BI Dashboard:** Open `sales_data.pbix` using Power BI Desktop to explore the interactive visual reports.
4.  **Excel Workbook:** Open `master.xlsx` to view the data models and pivot tables.
