# 🚚 Supply Chain Logistics & Delivery Performance Analytics

An end-to-end Data Analytics and Machine Learning project focused on analyzing logistics operations, delivery performance, SLA compliance, shipment costs, and route efficiency across multiple delivery partners.

The project combines **Python, SQL, Machine Learning, and Power BI** to transform raw shipment data into actionable business insights and predictive solutions.

---

## 📌 Project Overview

Efficient logistics operations are essential for maintaining delivery timelines, controlling transportation costs, and improving customer satisfaction.

This project analyzes shipment-level data to understand delivery performance, identify factors associated with SLA breaches, evaluate delivery partner efficiency, and predict delivery time and potential SLA failures.

The analysis covers 25,000 shipment records across six logistics partners, multiple Indian cities, five logistics zones, and different shipment conditions.

### Business Objectives

* Evaluate delivery partner performance and SLA compliance.
* Identify operational factors associated with shipment delays.
* Analyze the impact of weather and festival periods on delivery performance.
* Compare shipping costs across delivery partners and shipment modes.
* Understand route-level delivery and cost efficiency.
* Predict shipment transit time using regression models.
* Identify shipments at risk of SLA breaches using classification models.
* Develop an interactive Power BI dashboard for business reporting.

---

## 📂 Dataset Overview

**Dataset:** `india_multi_agency_edd_dataset.csv`

| Attribute          | Details           |
| ------------------ | ----------------- |
| Total Records      | 25,000 shipments  |
| Delivery Partners  | 6                 |
| Origin Cities      | 8                 |
| Destination Cities | 12                |
| Logistics Zones    | 5                 |
| Shipment Modes     | Air, Surface      |
| Weather Conditions | 4                 |
| Data Type          | Synthetic Dataset |

### Delivery Partners

* Blue Dart
* Delhivery
* Ekart
* Ecom Express
* XpressBees
* Shadowfax

### Important Dataset Columns

| Column                      | Description                        |
| --------------------------- | ---------------------------------- |
| Order_ID                    | Unique shipment identifier         |
| Delivery_Partner            | Logistics service provider         |
| Origin_City                 | Shipment origin                    |
| Destination_City            | Shipment destination               |
| Logistics_Zone              | Shipment distance/operational zone |
| Distance_km                 | Shipment distance                  |
| Shipment_Mode               | Air or Surface                     |
| Weight_kg                   | Shipment weight                    |
| Is_COD                      | Cash on Delivery indicator         |
| Shipping_Cost_INR           | Shipment transportation cost       |
| Weather_Condition           | Weather during shipment            |
| Festival_Peak               | Festival-period indicator          |
| Order_Timestamp             | Order creation timestamp           |
| Dispatch_Timestamp          | Shipment dispatch timestamp        |
| Pickup_Delay_Hours          | Pickup delay in hours              |
| Transit_Time_Hours          | Actual transit duration            |
| SLA_Promised_Days           | Promised delivery duration         |
| Expected_Delivery_Timestamp | Expected delivery timestamp        |
| Actual_Delivery_Days        | Actual delivery duration           |
| Is_Delayed_SLA              | SLA breach indicator               |

---

## 🛠️ Technologies Used

| Technology           | Purpose                                 |
| -------------------- | --------------------------------------- |
| Python               | Data cleaning, EDA and machine learning |
| Pandas               | Data manipulation                       |
| NumPy                | Numerical operations                    |
| Matplotlib / Seaborn | Exploratory data visualization          |
| Scikit-learn         | Machine learning and evaluation         |
| XGBoost              | Regression and classification           |
| PostgreSQL           | SQL analysis and querying               |
| pgAdmin 4            | Database management                     |
| Power BI             | Interactive dashboard development       |
| DAX                  | Measures and calculated columns         |
| Jupyter Notebook     | Development environment                 |

---

## 🔍 Project Workflow

### 1. Data Loading & Understanding

* Loaded the shipment dataset into Python.
* Examined dataset structure, dimensions, columns, and data types.
* Reviewed numerical and categorical variables.
* Identified important business metrics and prediction targets.

### 2. Data Cleaning & Preprocessing

* Converted timestamp columns into appropriate datetime formats.
* Checked missing values and duplicate records.
* Verified unique shipment identifiers.
* Checked data consistency and data quality.
* Investigated numerical outliers.

**Outlier Handling:**

Outliers were identified using the Interquartile Range (IQR) method.

The outliers were retained because unusually high delivery durations, shipment weights, and shipping costs can represent meaningful operational scenarios in logistics data.

### 3. Exploratory Data Analysis (EDA)

Performed detailed analysis to understand shipment operations and delivery performance.

Key areas explored:

* Overall shipment performance.
* Delivery partner comparison.
* Logistics zone performance.
* Shipment mode analysis.
* Weather-related delivery delays.
* Festival versus non-festival performance.
* Distance-based delivery analysis.
* Shipping cost and shipment weight relationships.

### 4. SQL Analysis – PostgreSQL

Loaded the cleaned dataset into PostgreSQL and performed analytical queries using:

* Joins and aggregations.
* Common Table Expressions (CTEs).
* Window functions.
* Conditional aggregation.
* Date and time functions.
* Ranking and analytical functions.
* Subqueries and filtering.

**Advanced business questions explored:**

* Monthly shipment volume and SLA breach trends.
* Delivery partner performance comparisons.
* High-volume origin-destination routes.
* Weather impact across logistics zones.
* Festival versus non-festival delivery performance.
* Consecutive SLA breaches.
* Shipping cost efficiency.
* Delivery time percentiles.
* High-risk routes by delivery partner.

### 5. Machine Learning – Delivery Time Prediction

**Problem Type:** Regression

**Target Variable:** `Transit_Time_Hours`

The objective was to predict shipment transit time using operational and shipment-related features available at dispatch.

Models evaluated:

* Linear Regression
* Random Forest Regressor
* XGBoost Regressor

#### Model Performance

| Model             | MAE (Hours) | RMSE (Hours) | R² Score |
| ----------------- | ----------: | -----------: | -------: |
| Linear Regression |        7.29 |         9.92 |   0.8624 |
| Random Forest     |        7.19 |         9.66 |   0.8694 |
| XGBoost           |        6.73 |         9.22 |   0.8812 |

**Best Model: XGBoost Regressor**

Key results:

* MAE: 6.73 hours
* RMSE: 9.22 hours
* R² Score: 0.8812

XGBoost achieved the best overall performance among the evaluated regression models.

The most influential predictive features included Logistics Zone, Shipment Mode, Delivery Partner, Distance, Weather Condition, and Festival Peak.

The trained model was saved as:

`xgboost_delivery_time_model.pkl`

### 6. Machine Learning – SLA Breach Prediction

**Problem Type:** Binary Classification

**Target Variable:** `Is_Delayed_SLA`

The objective was to predict whether a shipment would breach its promised delivery SLA.

Models evaluated:

* Logistic Regression
* Decision Tree
* Random Forest
* XGBoost Classifier

#### Model Performance

| Model               | Precision | Recall | F1 Score | ROC-AUC |
| ------------------- | --------: | -----: | -------: | ------: |
| Logistic Regression |    0.6718 | 0.8904 |   0.7658 |  0.9490 |
| Decision Tree       |    0.6896 | 0.6599 |   0.6744 |  0.7814 |
| Random Forest       |    0.8602 | 0.6591 |   0.7463 |  0.9430 |
| XGBoost             |    0.8326 | 0.7305 |   0.7782 |  0.9504 |

**Best Model by F1 Score and ROC-AUC: XGBoost Classifier**

Key results:

* Precision: 0.8326
* Recall: 0.7305
* F1 Score: 0.7782
* ROC-AUC: 0.9504

Logistic Regression achieved the highest recall (0.8904), making it another important candidate when minimizing missed SLA breaches is a priority.

Model selection depends on the operational cost of false positives and false negatives.

### 7. Power BI Dashboard Development

Developed a four-page interactive Power BI dashboard to communicate business performance and operational insights.

#### Page 1 – Executive Overview

Provides a high-level summary of shipment operations.

Key KPIs:

* Total Shipments
* On-Time Deliveries
* SLA Breach Rate
* Average Delivery Time

Visualizations:

* Monthly Shipment Volume Trend
* Delivery Status Distribution
* Shipment Distribution by Destination City
* Shipment Volume by Logistics Zone

#### Page 2 – Delivery Partner Performance

Evaluates delivery partner efficiency and service quality.

Key KPIs:

* Average Shipping Cost
* Average Transit Time
* Partner SLA Compliance Rate
* Partner SLA Breach Count
* Average Distance

Visualizations:

* Partner Cost vs Transit Time (Scatter Chart)
* Partner Shipping Cost Contribution (Waterfall Chart)
* Partner Performance Matrix

#### Page 3 – SLA & Delay Analysis

Investigates shipment delays and factors associated with SLA breaches.

Key KPIs:

* Delayed Shipment Percentage
* Average Pickup Delay
* Average Transit Time
* Average SLA Promised Days

Visualizations:

* Festival vs Non-Festival SLA Breaches
* SLA Breach Rate by Weather Condition
* Actual vs Promised Delivery Time (Gauge)
* SLA Breach Root Cause Analysis (Decomposition Tree)

#### Page 4 – Route & Cost Analysis

Focuses on transportation costs, distance, shipment modes, and route efficiency.

Key KPIs:

* Average Shipment Distance
* Average Shipment Weight
* Average Shipping Cost COD

Visualizations:

* Shipping Cost vs Distance Category
* Shipment Mode Distribution Across Logistics Zones
* COD vs Non-COD Shipping Cost Comparison
* Route-Level Cost Analysis Table

Interactive slicers enable users to explore shipment performance across different operational dimensions.

---

## 📊 Key Business Findings

The following findings were identified from the synthetic dataset.

### Overall Shipment Performance

| KPI                   |    Result |
| --------------------- | --------: |
| Total Shipments       |    25,000 |
| Average Delivery Time | 2.72 Days |
| Average Shipping Cost |   ₹142.97 |
| Average Distance      | 781.68 KM |
| SLA Breach Rate       |    25.52% |

### Delivery Partner Performance

| Delivery Partner | SLA Breach Rate |
| ---------------- | --------------: |
| Ecom Express     |          39.16% |
| XpressBees       |          34.91% |
| Delhivery        |          27.83% |
| Ekart            |          21.31% |
| Blue Dart        |          15.87% |
| Shadowfax        |          13.89% |

Shadowfax recorded the lowest SLA breach rate, while Ecom Express recorded the highest.

### Weather Impact

| Weather Condition | SLA Breach Rate |
| ----------------- | --------------: |
| Monsoon Storm     |          58.10% |
| Fog/Smog          |          35.36% |
| Rainy             |          28.91% |
| Clear             |          20.34% |

Monsoon Storm shipments recorded the highest SLA breach rate.

### Festival Impact

| Shipment Period | SLA Breach Rate |
| --------------- | --------------: |
| Non-Festival    |          21.23% |
| Festival        |          50.28% |

Festival-period shipments experienced a substantially higher SLA breach rate.

### Shipment Mode Comparison

| Shipment Mode | Average Shipping Cost | SLA Breach Rate |
| ------------- | --------------------: | --------------: |
| Surface       |               ₹126.02 |          26.34% |
| Air           |               ₹227.89 |          21.42% |

Air shipments had a higher average shipping cost but a lower SLA breach rate than Surface shipments.

### Logistics Zone Analysis

| Logistics Zone               | SLA Breach Rate |
| ---------------------------- | --------------: |
| Zone A – Intra-City          |          64.03% |
| Zone B – Within State/Region |          22.16% |
| Zone C – Metro-to-Metro      |          26.51% |
| Zone D – Rest of India       |           2.37% |
| Zone E – NE / J&K / Special  |           0.74% |

Zone A recorded an unusually high breach rate. This should be interpreted alongside its tighter promised delivery windows.

---

## 🎯 Project Outcomes & Achievements

Through this project, I:

* Analyzed 25,000 shipment records using Python and PostgreSQL.
* Performed data cleaning, validation, and exploratory analysis.
* Developed advanced SQL queries using CTEs and window functions.
* Built and evaluated multiple regression and classification models.
* Achieved an R² score of 0.8812 with the XGBoost regression model.
* Achieved a ROC-AUC score of 0.9504 with the XGBoost classification model.
* Identified key operational factors associated with SLA breaches.
* Developed an interactive four-page Power BI dashboard.
* Created DAX measures and calculated columns for business KPIs.
* Translated analytical findings into business-focused insights.

---

## 📁 Project Structure

A suggested repository structure:

```text
Supply-Chain-Logistics-Delivery-Analytics/
│
├── Dataset/
│   └── india_multi_agency_edd_dataset.csv
│
├── Notebooks/
│   ├── Data_Cleaning_EDA.ipynb
│   ├── SQL_Analysis.ipynb
│   ├── Delivery_Time_Prediction.ipynb
│   └── SLA_Breach_Prediction.ipynb
│
├── Models/
│   ├── xgboost_delivery_time_model.pkl
│   └── sla_breach_model.pkl
│
├── PowerBI/
│   ├── Supply_Chain_Dashboard.pbix
│   └── Supply_Chain_Dashboard.pdf
│
├── Screenshots/
│
└── README.md
```

*Note: The structure above is a suggested organization. Include only files that are actually available in the repository.*

---

## ⚠️ Disclaimer

This project uses a synthetic logistics dataset created for educational and portfolio purposes.

The delivery partner names, shipment records, operational metrics, and model results do not represent actual company performance or real-world logistics operations.

Machine learning results are based on the available synthetic dataset and should not be interpreted as production deployment performance.

---

## 👨‍💻 Author

**Papu Singh Deo**

Data Analyst | SQL | Python | Power BI | PostgreSQL | Machine Learning

Interested in transforming raw data into meaningful business insights through analytics, visualization, and predictive modeling.

