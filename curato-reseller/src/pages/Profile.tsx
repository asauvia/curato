import { useState, useEffect } from "react";
import { useGetResellerProfile, useUpdateResellerProfile, getGetResellerProfileQueryKey } from "@/api-client";
import { useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { User, Instagram, Youtube, Globe, CreditCard } from "lucide-react";

export default function Profile() {
  const { data: profile } = useGetResellerProfile();
  const qc = useQueryClient();
  const update = useUpdateResellerProfile();
  const [form, setForm] = useState({ name: "", mobile: "", pan: "", instagramProfile: "", youtubeChannel: "", socialMediaUrl: "" });

  useEffect(() => {
    if (profile) setForm({ name: profile.name, mobile: profile.mobile, pan: profile.pan ?? "", instagramProfile: profile.instagramProfile ?? "", youtubeChannel: profile.youtubeChannel ?? "", socialMediaUrl: profile.socialMediaUrl ?? "" });
  }, [profile]);

  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    update.mutate({ data: form }, {
      onSuccess: () => { qc.invalidateQueries({ queryKey: getGetResellerProfileQueryKey() }); toast.success("Profile updated!"); }
    });
  };

  return (
    <div className="p-8 max-w-2xl">
      <div className="mb-6">
        <h1 className="text-foreground font-normal tracking-tight text-2xl">My Profile</h1>
        <p className="text-muted-foreground text-sm mt-1">Manage your Reseller account details</p>
      </div>

      {/* Profile header */}
      <div className="bg-card rounded-xl border border-border p-6 mb-6">
        <div className="flex items-center gap-4">
          <div className="w-16 h-16 rounded-2xl bg-muted border-2 border-border flex items-center justify-center">
            <span className="text-foreground font-black text-2xl">{profile?.name?.charAt(0)}</span>
          </div>
          <div>
            <h2 className="text-foreground font-bold text-lg">{profile?.name}</h2>
            <p className="text-muted-foreground text-sm">{profile?.email}</p>
            <div className="flex items-center gap-2 mt-1">
              <span className="font-mono text-foreground text-xs font-semibold bg-muted border border-border px-2 py-0.5 rounded">{profile?.ResellerCode}</span>
              <span className={`text-xs font-medium px-2 py-0.5 rounded ${profile?.status === "Active" ? "bg-signal/10 text-signal" : "bg-muted text-foreground"}`}>{profile?.status}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Edit form */}
      <div className="bg-card rounded-xl border border-border p-6">
        <h3 className="font-semibold text-foreground mb-4">Edit Details</h3>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-foreground mb-1.5">Full Name</label>
              <input value={form.name} onChange={set("name")} className="w-full border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" />
            </div>
            <div>
              <label className="block text-sm font-medium text-foreground mb-1.5">Mobile Number</label>
              <input value={form.mobile} onChange={set("mobile")} className="w-full border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-foreground mb-1.5 flex items-center gap-1.5"><CreditCard size={14} /> PAN Number</label>
            <input value={form.pan} onChange={set("pan")} className="w-full border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="ABCDE1234F" />
          </div>

          <div className="border-t pt-4">
            <p className="text-xs font-semibold uppercase tracking-wider font-mono text-muted-foreground mb-3">Social Profiles</p>
            <div className="space-y-3">
              <div className="relative">
                <Instagram size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
                <input value={form.instagramProfile} onChange={set("instagramProfile")} className="w-full pl-9 border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="@instagram_handle" />
              </div>
              <div className="relative">
                <Youtube size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
                <input value={form.youtubeChannel} onChange={set("youtubeChannel")} className="w-full pl-9 border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="YouTube channel name or URL" />
              </div>
              <div className="relative">
                <Globe size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-foreground" />
                <input value={form.socialMediaUrl} onChange={set("socialMediaUrl")} className="w-full pl-9 border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="https://your-social-link.com" />
              </div>
            </div>
          </div>

          {update.error && <p className="text-red-500 text-sm">{(update.error as any)?.data?.error}</p>}
          <button type="submit" disabled={update.isPending} className="bg-foreground hover:bg-foreground/85 disabled:opacity-60 text-background font-semibold py-2.5 px-6 rounded-full text-sm transition-all">
            {update.isPending ? "Saving..." : "Save Changes"}
          </button>
        </form>
      </div>
    </div>
  );
}
