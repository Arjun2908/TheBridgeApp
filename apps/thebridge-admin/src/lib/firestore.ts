import { db } from './firebase';
import { collection, doc, getDocs, getDoc, setDoc, deleteDoc, query, orderBy, Timestamp } from 'firebase/firestore';
import { Resource } from './types';

export const resourcesCollection = collection(db, 'resources');

export const getResources = async (): Promise<Resource[]> => {
  const q = query(resourcesCollection, orderBy('createdAt', 'desc'));
  const snapshot = await getDocs(q);
  
  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
    createdAt: doc.data().createdAt.toDate(),
    updatedAt: doc.data().updatedAt.toDate(),
  })) as Resource[];
};

export const getResource = async (id: string): Promise<Resource | null> => {
  const docRef = doc(resourcesCollection, id);
  const docSnap = await getDoc(docRef);
  
  if (!docSnap.exists()) return null;
  
  return {
    id: docSnap.id,
    ...docSnap.data(),
    createdAt: docSnap.data().createdAt.toDate(),
    updatedAt: docSnap.data().updatedAt.toDate(),
  } as Resource;
};

export const createResource = async (data: Omit<Resource, 'id' | 'createdAt' | 'updatedAt'>) => {
  const docRef = doc(resourcesCollection);
  await setDoc(docRef, {
    ...data,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  });
  return docRef.id;
};

export const updateResource = async (id: string, data: Partial<Omit<Resource, 'id' | 'createdAt' | 'updatedAt'>>) => {
  const docRef = doc(resourcesCollection, id);
  await setDoc(docRef, {
    ...data,
    updatedAt: Timestamp.now(),
  }, { merge: true });
};

export const deleteResource = async (id: string) => {
  await deleteDoc(doc(resourcesCollection, id));
}; 