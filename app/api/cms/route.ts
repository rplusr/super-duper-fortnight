import { NextRequest, NextResponse } from 'next/server';
import { getCollections, updateCollections } from '@/lib/cms';

export async function GET() {
  try {
    const collections = getCollections();
    return NextResponse.json(collections);
  } catch (error) {
    console.error('CMS GET error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch collections' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const data = await request.json();
    updateCollections(data);
    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('CMS POST error:', error);
    return NextResponse.json(
      { error: 'Failed to update collections' },
      { status: 500 }
    );
  }
}
