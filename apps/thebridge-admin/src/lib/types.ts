export enum ResourceType {
  video = 'video',
  studyGuide = 'studyGuide',
}

export interface Resource {
  id: string;
  title: string;
  description: string;
  type: ResourceType;
  url: string;
  createdAt: Date;
  updatedAt: Date;
} 