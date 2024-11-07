import { db } from '../src/lib/firebase.js';
import { collection, doc, setDoc, Timestamp } from 'firebase/firestore';

const seedResources = async () => {
  const resources = [
    {
      title: 'How to read the Bible',
      description: 'Learn how to read the Bible for yourself',
      type: 'video',
      url: 'https://youtu.be/plSNIwhAn5o?si=lMCEmyouNdXl1Bo_',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    },
    {
      title: 'The Gospel',
      description: 'Learn the basics of the Christian faith',
      type: 'video',
      url: 'https://youtu.be/xrzq_X1NNaA?si=3SdDIvqiaKCDkAQu',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    },
    {
      title: "If You're Struggling With What to Pray About, Watch This",
      description: "Exploring the most well-known collection of Jesus' teachings, the Sermon on the Mount",
      type: 'video',
      url: 'https://youtu.be/3-YlqQfKkKk?si=SGII-rGFYTgScV5m',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    },
    {
      title: 'Bridge Illustration Guide',
      description: 'Comprehensive PDF guide with scripture references and presentation tips',
      type: 'studyGuide',
      url: 'https://navigators.org/wp-content/uploads/2017/08/navtool-bridge.pdf',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    },
    {
      title: 'Training Workbook',
      description: 'Interactive workbook for practicing and memorizing the Bridge presentation',
      type: 'studyGuide',
      url: 'https://www.navigators.org/resource/the-bridge-to-life/',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    },
  ];

  const batch = resources.map(async (resource) => {
    await setDoc(doc(collection(db, 'resources')), resource);
  });

  await Promise.all(batch);
  console.log('Resources seeded successfully!');
};

// Run the seed script
seedResources().catch(console.error); 