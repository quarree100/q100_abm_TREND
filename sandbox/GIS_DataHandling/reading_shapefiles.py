# -*- coding: utf-8 -*-
"""
2021-12-14

@author: dunland

read GIS shapefiles

"""

import geopandas as gp
import pandas as pd
import os

pd.set_option('display.max_rows', None) # display all rows when printed to console

# set input file:
file_shp = "includes/Shapefiles/bestandsgebaeude_export.shp"
file_geojson = "includes/geojson/gebaeudeliste-bestand.geojson"

df_shp = gp.read_file(file_shp)  # create dataframe
df_geojson = gp.read_file(file_geojson)

# show me all the columns of the dataframes:
print("shapefile:")
for col in df_shp.columns:
    print(col)

print("geojson:")
for col in df_geojson.columns:
    print(col)


df_compare = pd.DataFrame(df_geojson.columns, df_shp.columns)
print(df_compare)