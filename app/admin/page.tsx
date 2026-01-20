'use client';

import { useState, useEffect } from 'react';
import type { Collections } from '@/lib/cms';

export default function AdminPage() {
  const [collections, setCollections] = useState<Collections | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchCollections();
  }, []);

  const fetchCollections = async () => {
    try {
      const response = await fetch('/api/cms');
      const data = await response.json();
      setCollections(data);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching collections:', error);
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    setMessage('');

    try {
      const response = await fetch('/api/cms', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(collections),
      });

      if (response.ok) {
        setMessage('Changes saved successfully!');
      } else {
        setMessage('Failed to save changes');
      }
    } catch (error) {
      console.error('Error saving:', error);
      setMessage('Error saving changes');
    } finally {
      setSaving(false);
      setTimeout(() => setMessage(''), 3000);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen mt-16 flex items-center justify-center">
        <p>Loading...</p>
      </div>
    );
  }

  if (!collections) {
    return (
      <div className="min-h-screen mt-16 flex items-center justify-center">
        <p>Failed to load collections</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen mt-16 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="bg-white rounded-lg shadow-sm p-8">
          <h1 className="text-4xl font-light tracking-widest mb-8">CMS ADMIN</h1>

          {message && (
            <div className={`mb-6 p-4 rounded ${message.includes('success') ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
              {message}
            </div>
          )}

          {/* Hero Section */}
          <section className="mb-12 pb-12 border-b">
            <h2 className="text-2xl font-light tracking-wider mb-6">Hero Section</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Title</label>
                <input
                  type="text"
                  value={collections.hero.title}
                  onChange={(e) =>
                    setCollections({
                      ...collections,
                      hero: { ...collections.hero, title: e.target.value },
                    })
                  }
                  className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Subtitle</label>
                <input
                  type="text"
                  value={collections.hero.subtitle}
                  onChange={(e) =>
                    setCollections({
                      ...collections,
                      hero: { ...collections.hero, subtitle: e.target.value },
                    })
                  }
                  className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Image URL</label>
                <input
                  type="text"
                  value={collections.hero.image}
                  onChange={(e) =>
                    setCollections({
                      ...collections,
                      hero: { ...collections.hero, image: e.target.value },
                    })
                  }
                  className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                />
              </div>
            </div>
          </section>

          {/* Featured Products */}
          <section className="mb-12 pb-12 border-b">
            <h2 className="text-2xl font-light tracking-wider mb-6">Featured Products</h2>
            <div className="space-y-6">
              {collections.featured.map((product, index) => (
                <div key={product.id} className="p-4 bg-gray-50 rounded">
                  <h3 className="font-medium mb-4">Product {index + 1}</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-2">Name</label>
                      <input
                        type="text"
                        value={product.name}
                        onChange={(e) => {
                          const newFeatured = [...collections.featured];
                          newFeatured[index] = { ...product, name: e.target.value };
                          setCollections({ ...collections, featured: newFeatured });
                        }}
                        className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2">Price ($)</label>
                      <input
                        type="number"
                        value={product.price}
                        onChange={(e) => {
                          const newFeatured = [...collections.featured];
                          newFeatured[index] = { ...product, price: Number(e.target.value) };
                          setCollections({ ...collections, featured: newFeatured });
                        }}
                        className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2">Category</label>
                      <input
                        type="text"
                        value={product.category}
                        onChange={(e) => {
                          const newFeatured = [...collections.featured];
                          newFeatured[index] = { ...product, category: e.target.value };
                          setCollections({ ...collections, featured: newFeatured });
                        }}
                        className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2">Image URL</label>
                      <input
                        type="text"
                        value={product.image}
                        onChange={(e) => {
                          const newFeatured = [...collections.featured];
                          newFeatured[index] = { ...product, image: e.target.value };
                          setCollections({ ...collections, featured: newFeatured });
                        }}
                        className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* Categories */}
          <section className="mb-8">
            <h2 className="text-2xl font-light tracking-wider mb-6">Categories</h2>
            <div className="space-y-6">
              {collections.categories.map((category, index) => (
                <div key={index} className="p-4 bg-gray-50 rounded">
                  <h3 className="font-medium mb-4">Category {index + 1}</h3>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-2">Name</label>
                      <input
                        type="text"
                        value={category.name}
                        onChange={(e) => {
                          const newCategories = [...collections.categories];
                          newCategories[index] = { ...category, name: e.target.value };
                          setCollections({ ...collections, categories: newCategories });
                        }}
                        className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2">Link</label>
                      <input
                        type="text"
                        value={category.link}
                        onChange={(e) => {
                          const newCategories = [...collections.categories];
                          newCategories[index] = { ...category, link: e.target.value };
                          setCollections({ ...collections, categories: newCategories });
                        }}
                        className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2">Image URL</label>
                      <input
                        type="text"
                        value={category.image}
                        onChange={(e) => {
                          const newCategories = [...collections.categories];
                          newCategories[index] = { ...category, image: e.target.value };
                          setCollections({ ...collections, categories: newCategories });
                        }}
                        className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-black"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </section>

          <button
            onClick={handleSave}
            disabled={saving}
            className="w-full px-8 py-4 bg-black text-white hover:bg-gray-800 transition disabled:bg-gray-400 tracking-widest"
          >
            {saving ? 'SAVING...' : 'SAVE CHANGES'}
          </button>
        </div>
      </div>
    </div>
  );
}
