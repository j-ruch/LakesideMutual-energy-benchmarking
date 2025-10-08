const dbs = [
    "customercore",
    "customermanagement",
    "customerselfservice",
    "policymanagement"
];

dbs.forEach(dbName => {
    const targetDb = db.getSiblingDB(dbName);
    targetDb.createUser({
        user: "sa",
        pwd: "sa",
        roles: [{ role: "dbOwner", db: dbName }]
    });
});