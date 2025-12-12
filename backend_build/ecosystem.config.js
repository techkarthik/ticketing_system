module.exports = {
    apps: [{
        name: "ticketing-backend",
        script: "./server.js",
        env: {
            NODE_ENV: "production",
            PORT: 5000
        }
    }]
}
