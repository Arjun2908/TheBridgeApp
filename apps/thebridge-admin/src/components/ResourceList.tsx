'use client';

import { useState, useEffect } from 'react';
import { FiEdit, FiTrash2, FiPlus, FiPlay, FiFileText, FiChevronRight } from 'react-icons/fi';
import { Resource, ResourceType } from '../lib/types';
import { createResource, updateResource } from '../lib/firestore';
import ResourceForm from './ResourceForm';
import { collection, deleteDoc, doc, getDocs } from 'firebase/firestore';
import { db } from '@/lib/firebase';

export default function ResourceList() {
  const [resources, setResources] = useState<Resource[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingResource, setEditingResource] = useState<Resource | null>(null);
  const [activeTab, setActiveTab] = useState<ResourceType>(ResourceType.video);

  useEffect(() => {
    fetchResources();
  }, []);

  const fetchResources = async () => {
    try {
      const querySnapshot = await getDocs(collection(db, 'resources'));
      const resourceList = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Resource[];
      setResources(resourceList);
    } catch (error) {
      console.error('Error fetching resources:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm('Are you sure you want to delete this resource?')) {
      try {
        await deleteDoc(doc(db, 'resources', id));
        await fetchResources();
      } catch (error) {
        console.error('Error deleting resource:', error);
      }
    }
  };

  const handleCreate = async (data: Partial<Resource>) => {
    try {
      await createResource(data as Omit<Resource, 'id' | 'createdAt' | 'updatedAt'>);
      await fetchResources();
      setIsModalOpen(false);
    } catch (error) {
      console.error('Error creating resource:', error);
    }
  };

  const handleUpdate = async (data: Partial<Resource>) => {
    if (!editingResource) return;
    try {
      await updateResource(editingResource.id, data);
      await fetchResources();
      setEditingResource(null);
    } catch (error) {
      console.error('Error updating resource:', error);
    }
  };

  const handleEdit = (resource: Resource) => {
    setEditingResource(resource);
  };

  const filteredResources = resources.filter(resource => resource.type === activeTab);

  if (loading) return <div>Loading...</div>;

  return (
    <div className="container mx-auto px-4">
      <div className="mb-6 flex items-center justify-between">
        <h2 className="text-2xl font-semibold text-gray-200">Resources Preview</h2>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center rounded-md bg-indigo-600 px-4 py-2 text-white hover:bg-indigo-500"
        >
          <FiPlus className="mr-2" />
          Add Resource
        </button>
      </div>

      <div className="mb-6">
        <div className="flex space-x-4 border-b border-gray-700">
          <button 
            onClick={() => setActiveTab(ResourceType.video)}
            className={`flex items-center space-x-2 px-4 py-2 ${
              activeTab === ResourceType.video 
                ? 'border-b-2 border-indigo-500 text-indigo-400' 
                : 'text-gray-400 hover:text-gray-300'
            }`}
          >
            <FiPlay />
            <span>Videos</span>
          </button>
          <button 
            onClick={() => setActiveTab(ResourceType.studyGuide)}
            className={`flex items-center space-x-2 px-4 py-2 ${
              activeTab === ResourceType.studyGuide 
                ? 'border-b-2 border-indigo-500 text-indigo-400' 
                : 'text-gray-400 hover:text-gray-300'
            }`}
          >
            <FiFileText />
            <span>Study Guides</span>
          </button>
        </div>
      </div>

      <div className="space-y-4">
        {filteredResources.map((resource) => (
          <div
            key={resource.id}
            className="group relative overflow-hidden rounded-2xl bg-gray-800 p-4 shadow-lg transition-all hover:scale-[0.99]"
          >
            <div className="flex items-start space-x-4">
              <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-indigo-900/50">
                {resource.type === ResourceType.video ? (
                  <FiPlay className="h-7 w-7 text-indigo-400" />
                ) : (
                  <FiFileText className="h-7 w-7 text-indigo-400" />
                )}
              </div>
              
              <div className="flex-1">
                <h3 className="font-semibold text-gray-100">{resource.title}</h3>
                <p className="mt-1 text-sm text-gray-400">{resource.description}</p>
                <a 
                  href={resource.url}
                  target="_blank"
                  rel="noopener noreferrer" 
                  className="mt-2 inline-flex items-center text-sm text-indigo-400 hover:text-indigo-300"
                >
                  View Resource
                  <FiChevronRight className="ml-1" />
                </a>
              </div>

              <div className="flex space-x-2 opacity-0 transition-opacity group-hover:opacity-100">
                <button
                  onClick={() => handleEdit(resource)}
                  className="rounded-full p-2 text-gray-400 hover:bg-gray-700 hover:text-gray-200"
                >
                  <FiEdit className="h-5 w-5" />
                </button>
                <button
                  onClick={() => handleDelete(resource.id)}
                  className="rounded-full p-2 text-gray-400 hover:bg-red-900/50 hover:text-red-400"
                >
                  <FiTrash2 className="h-5 w-5" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {(isModalOpen || editingResource) && (
        <div className="fixed inset-0 z-10 overflow-y-auto">
          <div className="flex min-h-screen items-end justify-center px-4 pb-20 pt-4 text-center sm:block sm:p-0">
            <div className="fixed inset-0 transition-opacity" aria-hidden="true">
              <div className="absolute inset-0 bg-gray-900 opacity-75"></div>
            </div>
            <div className="inline-block transform overflow-hidden rounded-lg bg-gray-900 px-4 pb-4 pt-5 text-left align-bottom shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6 sm:align-middle">
              <h3 className="mb-4 text-lg font-medium leading-6 text-gray-200">
                {editingResource ? 'Edit Resource' : 'Add Resource'}
              </h3>
              <ResourceForm
                resource={editingResource || undefined}
                onSubmit={editingResource ? handleUpdate : handleCreate}
                onCancel={() => {
                  setIsModalOpen(false);
                  setEditingResource(null);
                }}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  );
} 