const http = require("http");

const server = http.createServer((request, response) => {
  response.writeHead(200, { "Content-Type": "text/html" });
  response.end("<h1>Hello World from Node.js</h1>");
});

server.listen(3000, "0.0.0.0", () => {
  console.log("Node.js app is running on port 3000");
});
