import pandas as pd
from datetime import datetime

timestamp = datetime.now().strftime('%Y%m%d%H%M%S')

# Load the CSV data
csv_file_path = './data/csv/input_example.csv'
csv_data = pd.read_csv(csv_file_path)

# output_file_path = csv_file_path.replace('.csv', '.sparql')
# output_file_path = output_file_path.replace('./data/csv', './config/migrations')
output_file_path = f'./config/migrations/{timestamp}-aanduidingsobjecten.sparql'

# Define the file header with PREFIX namespaces
file_header = """
PREFIX oe: <https://id.erfgoed.net/vocab/ontology#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX adms: <http://www.w3.org/ns/adms#>
PREFIX locn: <http://www.w3.org/ns/locn#>
PREFIX adres: <https://data.vlaanderen.be/ns/adres#>
PREFIX person: <http://www.w3.org/ns/person#>
PREFIX schema: <http://schema.org/>

INSERT DATA {
  GRAPH <http://mu.semte.ch/graphs/organizations/974816591f269bb7d74aa1720922651529f3d3b2a787f5c60b73e5a0384950a4> {

"""


# Function to convert each row to a TTL format using the PREFIX namespaces
def row_to_ttl(row):
    # Convert row values to strings and handle NaN values
    typologie = row['typologie'] if pd.notna(row['typologie']) else ""
    gebeurtenissen = row['gebeurtenissen'] if pd.notna(row['gebeurtenissen']) else ""
    geldig_tot = row['geldig tot'] if pd.notna(row['geldig tot']) else ""
    besluiten = row['besluiten'] if pd.notna(row['besluiten']) else ""
    toelatingsplichtige = row['toelatingsplichtige handelingen'] if pd.notna(
        row['toelatingsplichtige handelingen']) else ""

    return f"""
oe:{row['id']}
    a oe:{row['type'].replace(' ', '')} ;
    dct:identifier "{row['id']}" ;
    dct:title "{row['naam']}" ;
    schema:location "{row['locatie']}" ;
    schema:address [
        locn:adminUnitL2 "{row['provincie']}"@nl ;
        locn:fullAddress "{row['deelgemeente']}, {row['gemeente']}, {row['provincie']}"@nl
    ] ;
    oe:typologie "{typologie}" ;
    oe:gebeurtenissen "{gebeurtenissen}" ;
    dct:valid "{row['geldig vanaf']}"^^xsd:date ;
    dct:expires "{geldig_tot}"^^xsd:date ;
    oe:besluiten "{besluiten}" ;
    dct:creator "{row['dataverantwoordelijke']}" ;
    oe:toelatingsplichtigeHandelingen "{toelatingsplichtige}" .
"""


# Open the output file in write mode
with open(output_file_path, 'w') as file:
    # Write the header with PREFIX namespaces
    file.write(file_header)

    # Iterate over each row and write the TTL representation to the file
    for index, row in csv_data.iterrows():
        ttl_representation = row_to_ttl(row)
        file.write(ttl_representation)

    # Add a closing brace at the end
    file.write("\n  }\n}")

print(f"TTL data has been written to {output_file_path}")
