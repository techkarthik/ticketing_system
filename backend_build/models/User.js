const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true
    },
    personName: {
        type: String,
        required: false,
        default: 'Unknown'
    },
    branch: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Branch',
        required: false // Setting false initially to avoid breaking existing users on startup, but UI will enforce it.
    },
    department: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Department',
        required: false
    },
    password: {
        type: String,
        required: true
    },
    mobilenumber: {
        type: String,
        required: true
    },
    role: {
        type: String,
        enum: ['SUPERADMIN', 'ADMIN', 'STAFF'],
        default: 'STAFF'
    },
    isadmin: {
        type: Boolean,
        default: false
    }
}, { timestamps: true });

module.exports = mongoose.model('Usermaster', userSchema);
