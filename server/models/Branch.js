const mongoose = require('mongoose');

const branchSchema = new mongoose.Schema({
    branchname: {
        type: String,
        required: true,
        trim: true,
        unique: true
    },
    location: {
        type: String,
        required: true,
        trim: true
    },
    active: {
        type: Boolean,
        default: true
    },
    branchtype: {
        type: String,
        enum: ['RETAIL', 'FACTORY', 'WHOLESALE'],
        required: true
    }
}, { timestamps: true });

module.exports = mongoose.model('Branch', branchSchema);
