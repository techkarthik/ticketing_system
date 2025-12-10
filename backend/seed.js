const mongoose = require('mongoose');
const Branch = require('./models/Branch');
const Category = require('./models/Category');
require('dotenv').config();

mongoose.connect('mongodb+srv://techkarthikmahalingam:PFXpa8U4GupQNRe0@cluster0.wkrky.mongodb.net/ticketing_system', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log('MongoDB Connected for Seeding'))
    .catch(err => console.log(err));

const seedData = async () => {
    try {
        // Seed Branches
        const branches = [
            'Chennai', 'Trichy', 'Salem', 'Coimbatore', 'Madurai', 'Tirunelveli',
            'Erode', 'Vellore', 'Thanjavur', 'Kanyakumari'
        ];

        for (const branchName of branches) {
            const exists = await Branch.findOne({ name: branchName });
            if (!exists) {
                await Branch.create({ name: branchName });
                console.log(`Branch created: ${branchName}`);
            }
        }

        // Seed Categories
        const categories = [
            { name: 'Software', type: 'IT' },
            { name: 'Hardware', type: 'IT' },
            { name: 'Internal Function', type: 'General' },
            { name: 'External Function', type: 'General' }
        ];

        for (const cat of categories) {
            const exists = await Category.findOne({ name: cat.name });
            if (!exists) {
                await Category.create(cat);
                console.log(`Category created: ${cat.name}`);
            }
        }

        console.log('Seeding Completed');
        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

seedData();
