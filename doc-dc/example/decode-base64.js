
// Using read line to get user input
// https://stackoverflow.com/questions/18193953/waiting-for-user-to-enter-input-in-node-js
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('What do you think of Node.js? ', (answer) => {
  // TODO: Log the answer in a database
  console.log(`Thank you for your valuable feedback: ${answer}`);

  // https://stackoverflow.com/questions/6182315/how-to-do-base64-encoding-in-node-js

  // console.log(Buffer.from("Hello World").toString('base64'));
  // SGVsbG8gV29ybGQ =
  console.log(Buffer.from(`${answer}`, 'base64').toString('ascii'))
// Hello World


  rl.close();
});

// https://stackoverflow.com/questions/6182315/how-to-do-base64-encoding-in-node-js

// console.log(Buffer.from("Hello World").toString('base64'));
// SGVsbG8gV29ybGQ =
//console.log(Buffer.from(ans, 'base64').toString('ascii'))
// Hello World
