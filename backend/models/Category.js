const mongoose = require('mongoose');

const CategorySchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        unique: true
    },
    type: {
        type: String, // e.g., 'Hardware', 'Software', 'Function'
        default: 'General'
    }
});

module.exports = mongoose.model('Category', CategorySchema);
