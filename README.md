# 🗳️ WhoWins 2029

An interactive machine learning-based election forecasting platform that predicts **state-wise Lok Sabha election winners** using historical election data. Built with **R Shiny**, **Random Forest**, **Plotly**, and **GeoJSON**, the application provides an intuitive dashboard for visualizing election predictions, historical trends, and party-wise seat distributions across India.

---

## ✨ Features

- 🗺️ Interactive India map displaying predicted winning parties state-wise.
- 🤖 Random Forest model trained on historical election data for forecasting future election outcomes.
- 📊 Historical seat distribution analysis (2014–2024).
- 🥧 Party-wise seat share visualization using interactive charts.
- 🔍 Dynamic prediction updates based on the selected base election year.
- 📈 Interactive dashboards powered by Plotly.
- 🌍 GIS-based visualization using GeoJSON state boundaries.
- 🎨 Political party color coding and logo integration for better visualization.

---

## 🛠️ Tech Stack

### Frontend

- R Shiny
- Plotly
- ggplot2

### Machine Learning

- Random Forest
- Data Preprocessing
- Feature Engineering

### Data Visualization

- Plotly
- ggplot2
- sf (Simple Features)
- GeoJSON
- tmap

### Data

- Historical Lok Sabha Election Dataset
- India State Boundary GeoJSON

---

# How It Works

## 1. Data Preparation

Historical election data containing constituency-level information is processed to generate features including:

- Vote Share
- Vote Margin
- Swing Votes
- Turnout Impact
- Incumbency

Synthetic variations are introduced to simulate future election scenarios.

---

## 2. Prediction Pipeline

The Random Forest model predicts the likely winning political party for every constituency.

The predictions are then aggregated to:

- Constituency Winners
- State-wise Winners
- Overall Party Performance

---

## 3. Interactive Dashboard

Users can choose a historical election year as the base year.

The application automatically generates predictions for the next election cycle and visualizes:

- State-wise winning party
- Interactive India map
- Historical seat trends
- Party-wise seat share

---

## 📊 Dashboard Components

### 🗺️ Election Prediction Map

Displays predicted winning parties across Indian states using interactive GIS visualization.

Features include:

- Hover tooltips
- State-wise winner information
- Political party color coding
- Interactive zoom and pan

---

### 📈 Historical Seat Trends

Area chart showing seat distribution trends between major political parties across multiple election years.

---

### 🥧 Party Seat Distribution

Pie chart illustrating party-wise seat share for the selected election year.

---

## 📂 Project Structure

```text
WhoWins2029/
│
├── app.R
├── model_rf_party.rds
├── election_data_features_filtered.csv
├── india_states.geojson
├── bjp.jpg
├── congress.jpg
│
├── data/
│
├── models/
│
└── README.md
```

---

# Machine Learning Workflow

```text
Historical Election Data
            │
            ▼
   Feature Engineering
            │
            ▼
    Random Forest Model
            │
            ▼
 Constituency Predictions
            │
            ▼
 State-wise Aggregation
            │
            ▼
 Interactive India Map
            │
            ▼
 Historical Analytics Dashboard
```

---

## 📦 Installation

Clone the repository

```bash
git clone https://github.com/yourusername/WhoWins2029.git
```

Install required packages

```r
install.packages(c(
  "shiny",
  "tidyverse",
  "randomForest",
  "plotly",
  "ggplot2",
  "sf",
  "geodata",
  "tmap",
  "jpeg"
))
```

Place the following files inside the project directory:

- model_rf_party.rds
- election_data_features_filtered.csv
- india_states.geojson
- bjp.jpg
- congress.jpg

---

## ▶️ Run the Application

```r
shiny::runApp()
```

The application launches locally in your browser.

---

## 📌 Future Improvements

- Add predictions for additional political parties.
- Incorporate constituency-level visualization.
- Deploy the application on Shiny Server or Posit Connect.
- Integrate real-time election datasets.
- Compare predictions against actual election outcomes.
- Include confidence scores for predictions.
- Enhance the model using Gradient Boosting or XGBoost.
- Add downloadable reports and analytics.

---





## 👨‍💻 Author

**Amar Sinha**

B.Tech Computer Science Engineering (Data Science)

Heritage Institute of Technology, Kolkata



---

## 📜 License

This project is intended for educational and research purposes.
