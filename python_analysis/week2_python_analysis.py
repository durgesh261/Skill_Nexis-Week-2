"""
Week 2: Python for Data Analysis
Practice Questions Solutions
Dataset: Awesome Chocolates Sales Dataset (chocolate_sales.csv)
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

def run_python_analysis():
    print("=" * 80)
    print("WEEK 2: PYTHON FOR DATA ANALYSIS — PRACTICE QUESTIONS")
    print("=" * 80)
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_path = os.path.join(script_dir, "..", "data", "chocolate_sales.csv")
    output_img = os.path.join(script_dir, "correlation_matrix.png")
    
    # -------------------------------------------------------------------------
    # Question 1: Load a CSV file using Pandas and display basic info
    # -------------------------------------------------------------------------
    print("\n" + "#" * 80)
    print("QUESTION 1: Load a CSV file using Pandas and display basic info")
    print("#" * 80)
    
    df = pd.read_csv(data_path)
    print(f"\n[1.1] Dataset successfully loaded from: {data_path}")
    print(f"[1.2] DataFrame Shape: {df.shape[0]} rows, {df.shape[1]} columns")
    
    print("\n[1.3] DataFrame Head (First 5 Rows):")
    print(df.head())
    
    print("\n[1.4] DataFrame Info:")
    df.info()
    
    print("\n[1.5] Data Types of Columns:")
    print(df.dtypes)
    
    print("\n[1.6] Summary Statistics (Numerical Columns):")
    print(df.describe())
    
    # -------------------------------------------------------------------------
    # Question 2: Handle missing values and duplicates using Pandas
    # -------------------------------------------------------------------------
    print("\n" + "#" * 80)
    print("QUESTION 2: Handle missing values and duplicates using Pandas")
    print("#" * 80)
    
    # Check initial missing values
    null_counts = df.isnull().sum()
    print("\n[2.1] Missing Values Count per Column (Before Cleaning):")
    print(null_counts)
    
    # Check duplicates
    duplicate_count = df.duplicated().sum()
    print(f"\n[2.2] Duplicate Rows Count (Before Cleaning): {duplicate_count}")
    
    # Cleaning actions
    df_cleaned = df.copy()
    
    # Fill missing team values if any
    if "Team" in df_cleaned.columns and df_cleaned["Team"].isnull().sum() > 0:
        df_cleaned["Team"] = df_cleaned["Team"].fillna("Unassigned")
        print("-> Imputed missing values in 'Team' with 'Unassigned'.")
    else:
        df_cleaned["Team"] = df_cleaned["Team"].fillna("Unassigned")
        print("-> Verified categorical imputation strategy (fillna with 'Unassigned').")
        
    # Remove any potential duplicate rows
    initial_len = len(df_cleaned)
    df_cleaned = df_cleaned.drop_duplicates()
    final_len = len(df_cleaned)
    print(f"[2.3] Executed drop_duplicates(): Removed {initial_len - final_len} duplicate rows.")
    print(f"[2.4] Final Missing Values Count: {df_cleaned.isnull().sum().sum()}")
    print(f"[2.5] Cleaned DataFrame Shape: {df_cleaned.shape}")

    # -------------------------------------------------------------------------
    # Question 3: Group data by category and find total revenue
    # -------------------------------------------------------------------------
    print("\n" + "#" * 80)
    print("QUESTION 3: Group data by category and find total revenue")
    print("#" * 80)
    
    category_summary = df_cleaned.groupby("Category").agg(
        Total_Revenue=("Amount", "sum"),
        Average_Order_Value=("Amount", "mean"),
        Total_Boxes_Sold=("Boxes", "sum"),
        Total_Shipments=("Amount", "count")
    ).reset_index()
    
    # Calculate revenue share
    total_revenue_all = category_summary["Total_Revenue"].sum()
    category_summary["Revenue_Share_%"] = (category_summary["Total_Revenue"] / total_revenue_all) * 100
    category_summary = category_summary.sort_values(by="Total_Revenue", ascending=False)
    
    print("\n[3.1] Category-Wise Revenue and Performance Table:")
    formatted_summary = category_summary.copy()
    formatted_summary["Total_Revenue"] = formatted_summary["Total_Revenue"].apply(lambda x: f"${x:,.2f}")
    formatted_summary["Average_Order_Value"] = formatted_summary["Average_Order_Value"].apply(lambda x: f"${x:,.2f}")
    formatted_summary["Total_Boxes_Sold"] = formatted_summary["Total_Boxes_Sold"].apply(lambda x: f"{x:,}")
    formatted_summary["Total_Shipments"] = formatted_summary["Total_Shipments"].apply(lambda x: f"{x:,}")
    formatted_summary["Revenue_Share_%"] = formatted_summary["Revenue_Share_%"].apply(lambda x: f"{x:.2f}%")
    print(formatted_summary.to_string(index=False))

    # -------------------------------------------------------------------------
    # Question 4: Sort data by multiple columns using Python
    # -------------------------------------------------------------------------
    print("\n" + "#" * 80)
    print("QUESTION 4: Sort data by multiple columns using Python")
    print("#" * 80)
    
    # Multi-column sort 1: By Category (Ascending) and Amount (Descending)
    df_sorted_cat_amount = df_cleaned.sort_values(
        by=["Category", "Amount"],
        ascending=[True, False]
    )
    print("\n[4.1] Sorted by Category (Ascending) & Amount (Descending) - Top 10:")
    print(df_sorted_cat_amount[["Category", "Product", "Salesperson", "Country", "Amount", "Boxes"]].head(10).to_string(index=False))
    
    # Multi-column sort 2: By Country (Ascending) and SaleDate (Ascending)
    df_sorted_geo_date = df_cleaned.sort_values(
        by=["Country", "SaleDate"],
        ascending=[True, True]
    )
    print("\n[4.2] Sorted by Country (Ascending) & SaleDate (Ascending) - First 5:")
    print(df_sorted_geo_date[["Country", "SaleDate", "Product", "Salesperson", "Amount"]].head(5).to_string(index=False))

    # -------------------------------------------------------------------------
    # Question 5: Create a correlation matrix for numerical columns
    # -------------------------------------------------------------------------
    print("\n" + "#" * 80)
    print("QUESTION 5: Create a correlation matrix for numerical columns")
    print("#" * 80)
    
    numeric_cols = ["Amount", "Customers", "Boxes", "Cost_per_box"]
    corr_matrix = df_cleaned[numeric_cols].corr()
    
    print("\n[5.1] Correlation Matrix Table:")
    print(corr_matrix.round(4))
    
    # Generate Heatmap using Matplotlib & Seaborn
    plt.figure(figsize=(8, 6))
    sns.heatmap(
        corr_matrix,
        annot=True,
        cmap="coolwarm",
        fmt=".3f",
        linewidths=1,
        square=True,
        cbar_kws={"shrink": 0.8}
    )
    plt.title("Correlation Matrix — Numerical Attributes (Awesome Chocolates)", fontsize=14, pad=15, fontweight="bold")
    plt.tight_layout()
    plt.savefig(output_img, dpi=300)
    plt.close()
    print(f"\n[5.2] Correlation heatmap visual saved to: {output_img}")
    
    print("\n" + "=" * 80)
    print("ALL 5 PYTHON PRACTICE QUESTIONS COMPLETED SUCCESSFULLY!")
    print("=" * 80)

if __name__ == "__main__":
    run_python_analysis()
