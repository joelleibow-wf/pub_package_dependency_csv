// Load the CSV and only create Package nodes if they don't already exist.
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///<YOUR CSV FILE PATH RELATIVE TO THE NEO4J IMPORT DIRECTORY>" AS row
MERGE (p:Package {packageName: row.package, resolvedVersion: row.resolvedVersion, sdkConstraint: row.sdkConstraint});

// Add an index on the package name since we'll use that to define our relationships.
CREATE INDEX ON :Package(packageName);

// Again using the data within the CSV, create the relationships for all existing Package nodes.
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///<YOUR CSV FILE PATH RELATIVE TO THE NEO4J IMPORT DIRECTORY>" AS row
MATCH (package:Package {packageName: row.package})
MATCH (dependant:Package {packageName: row.dependant})
MERGE (dependant)-[:DEPENDS_ON]->(package)

// Potentially useful queries

// Get the Packages sorted by the number of dependencies most to least
MATCH (package:Package)-[dependsOn:DEPENDS_ON]->(dependency:Package)
RETURN package, count(dependsOn) AS dependencies
ORDER BY dependencies DESC

// Get the Packages sorted by the number of dependants most to least
MATCH (dependency:Package)<-[dependedOn:DEPENDS_ON]-(package:Package)
RETURN dependency, count(dependedOn) AS dependants
ORDER BY dependants DESC
