function parse_payload(args) {
    var fs = require('fs');
    var payloadIndex = -1;

    args.forEach(function (val, index, array) {
        if (val == "-payload") {
            payloadIndex = index + 1;
        }
    });

    if (payloadIndex == -1) {
        console.error("No payload argument");
        process.exit(1);
    }

    if (payloadIndex >= args.length) {
        console.error("No payload value");
        process.exit(1);
    }

    return JSON.parse(fs.readFileSync(args[payloadIndex], 'ascii'))
}

module.exports = parse_payload(process.argv)
