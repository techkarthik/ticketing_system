const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');
require('dotenv').config();

const checkAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);

        const user = await User.findOne({ username: 'techkarthikmahalingam@gmail.com' });
        if (!user) {
            console.log('User not found!');
            return;
        }

        console.log('User found:', user.username);
        console.log('Stored Hash:', user.password);

        const isMatch = await bcrypt.compare('admin', user.password);
        console.log("Checking against 'admin':", isMatch);

        if (!isMatch) {
            console.log('RESETTING PASSWORD TO "admin"...');
            const salt = await bcrypt.genSalt(10);
            user.password = await bcrypt.hash('admin', salt);
            await user.save();
            console.log('Password reset complete.');
        }

    } catch (e) {
        console.error(e);
    } finally {
        mongoose.disconnect();
    }
};

checkAdmin();
