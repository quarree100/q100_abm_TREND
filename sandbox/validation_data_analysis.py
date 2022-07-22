import os
import datetime
import pandas
import matplotlib.pyplot as plt

############################ data ##############################
print("cwd:", os.getcwd())
validation_outputs_path = "../data/validation_20220722_000"

results = []

# walk through folders, find files with net data:
for root, dirs, files in sorted(os.walk(validation_outputs_path)):
    for name in files:
        if name.__eq__("csv_export_co2_graph_test_neighborhood.csv"):
            print(root, name)
            results.append(pandas.read_csv(os.path.join(os.getcwd(), root, name)))

print(results[0].columns)

# plot line names:
labels = [
    'Ref_Q100', 'Ref_all',
    '1_Q100', '1_all',
    '2_Q100', '2_all',
    '5_Q100', '5_all',
    '10_Q100', '10_all',
    '20_Q100', '20_all',
    '40_Q100', '40_all', ]

####################### create plot 1: ########################
ax0 = plt.gca()
# plt.figure(0)

# add data:
i = 0
for df in results:

    df.plot(kind='line', x='current_date', y='emissions_neighborhood_total', label=labels[i], ax=ax0)
    i += 1

# plot design:
plt.title("Batch Simulation 2022-07-22_000")
plt.suptitle("Total Neighborhood Emissions")
plt.xlabel("time")
plt.ylabel("Total Neighborhood Emissions [g of CO2]")
plt.xticks(rotation=30)

####################### create plot 2: ########################
plt.figure(1)
ax1 = plt.gca()

# add data:
i = 0
for df in results:

    df.plot(kind='line', x='current_date', y='emissions_neighborhood_accu', label=labels[i], ax=ax1)
    i += 1

# plot design:
plt.title("Batch Simulation 2022-07-22_000")
plt.suptitle("Total Neighborhood Emissions accumulated")
plt.xlabel("time")
plt.ylabel("Total Neighborhood Emissions, accumulated [g of CO2]")
plt.xticks(rotation=30)

####################### create plot 3: ########################
plt.figure(2)
ax2 = plt.gca()

# add data:
i = 0
for df in results:

    df.plot(kind='line', x='current_date', y='emissions_household_average', label=labels[i], ax=ax2)
    i += 1

# plot design:
plt.title("Batch Simulation 2022-07-22_000")
plt.suptitle("Household Average Emissions")
plt.xlabel("time")
plt.ylabel("Total Average Household Emissions [g of CO2]")
plt.xticks(rotation=30)

####################### create plot 4: ########################
plt.figure(3)
ax3 = plt.gca()

# add data:
i = 0
for df in results:

    df.plot(kind='line', x='current_date', y='emissions_household_average_accu', label=labels[i], ax=ax3)
    i += 1

# plot design:
plt.title("Batch Simulation 2022-07-22_000")
plt.suptitle("Household Average Emissions accumulated")
plt.xlabel("time")
plt.ylabel("Total Average Household Emissions, accumulated [g of CO2]")
plt.xticks(rotation=30)

####################### create plot 5: ########################
plt.figure(4)
ax4 = plt.gca()

# add data:
i = 0
for df in results:

    df.plot(kind='line', x='current_date', y='modernization_rate', label=labels[i], ax=ax4)
    i += 1

# plot design:
plt.title("Batch Simulation 2022-07-22_000")
plt.suptitle("Modernization rate")
plt.xlabel("time")
plt.ylabel("renovations")
plt.xticks(rotation=30)

plt.show()

exit()