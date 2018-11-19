// Load the CSV and only create Package nodes if they don't already exist.
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///<YOUR CSV FILE PATH RELATIVE TO THE NEO4J IMPORT DIRECTORY>" AS row
MERGE (p:Package {
  packageName: row.package,
  resolvedVersion: row.resolvedVersion,
  sdkConstraint: row.sdkConstraint,
  isHosted: (case row.isHosted when "true" then true else false end),
  supportsDart2: (case row.supportsProvidedSdkVersion when "true" then true else false end)
});

// Add an index on the package name since we'll use that to define our relationships.
CREATE INDEX ON :Package(packageName);

// Again using the data within the CSV, create the DEPENDS_ON relationship for all existing Package nodes.
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///<YOUR CSV FILE PATH RELATIVE TO THE NEO4J IMPORT DIRECTORY>" AS row
MATCH (package:Package {
  packageName: row.package
})
MATCH (dependent:Package {
  packageName: row.dependent
})
MERGE (dependent)-[:DEPENDS_ON]->(package)

// And the DEV_DEPENDS_ON relationship for all existing Package nodes.
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///<YOUR CSV FILE PATH RELATIVE TO THE NEO4J IMPORT DIRECTORY>" AS row
MATCH (package:Package {
  packageName: row.package
})
MATCH (devDependent:Package {
  packageName: row.devDependent
})
MERGE (devDependent)-[:DEV_DEPENDS_ON]->(package)
