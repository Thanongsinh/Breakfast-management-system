import { TopBar } from '@/components/layout/TopBar';
import { OwnerSidebar } from '@/components/layout/OwnerSidebar';

export default function OwnerLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-gray-50">
      <TopBar />
      <div className="flex">
        <OwnerSidebar />
        <main className="flex-1 p-8">{children}</main>
      </div>
    </div>
  );
}
