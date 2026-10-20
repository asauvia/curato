import { Link, useLocation } from "wouter";
import { useAuth } from "@/hooks/useAuth";
import { useLogoutReseller, getGetCurrentUserQueryKey } from "@/api-client";
import { useQueryClient } from "@tanstack/react-query";
import { cn } from "@/lib/utils";
import { useState, useEffect } from "react";
import {
  LayoutDashboard, Package, ShoppingBag, Link2, Wallet, ArrowDownToLine,
  BarChart2, User, ChevronRight, LogOut, Settings, Users, CreditCard,
  TrendingUp, ShoppingCart, Award, Menu, X, FolderOpen
} from "lucide-react";

const ResellerNav = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/products", label: "Browse Products", icon: Package },
  { href: "/my-products", label: "My Products", icon: ShoppingBag },
  { href: "/collections", label: "My Collections", icon: FolderOpen },
  { href: "/referrals", label: "Referral Links", icon: Link2 },
  { href: "/orders", label: "Orders", icon: ShoppingCart },
  { href: "/wallet", label: "Wallet", icon: Wallet },
  { href: "/withdrawals", label: "Withdrawals", icon: ArrowDownToLine },
  { href: "/analytics", label: "Analytics", icon: BarChart2 },
  { href: "/profile", label: "Profile", icon: User },
];

const adminNav = [
  { href: "/admin", label: "Dashboard", icon: LayoutDashboard },
  { href: "/admin/Resellers", label: "Resellers", icon: Users },
  { href: "/admin/withdrawals", label: "Withdrawals", icon: CreditCard },
  { href: "/admin/analytics", label: "Analytics", icon: TrendingUp },
  { href: "/admin/top-Resellers", label: "Top Performers", icon: Award },
];

const vendorNav = [
  { href: "/vendor/orders", label: "Orders", icon: ShoppingCart },
];

function NavItem({ href, label, icon: Icon }: { href: string; label: string; icon: any }) {
  const [location] = useLocation();
  const active = location === href || (href !== "/" && href !== "/admin" && location.startsWith(href));
  return (
    <Link href={href}>
      <div className={cn(
        "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all cursor-pointer",
        active
          ? "bg-muted text-foreground"
          : "text-muted-foreground hover:text-foreground hover:bg-muted"
      )}>
        <Icon size={17} className={active ? "text-foreground" : ""} />
        <span>{label}</span>
        {active && <ChevronRight size={14} className="ml-auto text-foreground" />}
      </div>
    </Link>
  );
}

export function Layout({ children }: { children: React.ReactNode }) {
  const { user, role } = useAuth();
  const qc = useQueryClient();
  const logout = useLogoutReseller();
  const [location, navigate] = useLocation();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  // Close mobile menu when location changes
  useEffect(() => {
    setIsMobileMenuOpen(false);
  }, [location]);

  const navItems = role === "admin" ? adminNav : role === "vendor" ? vendorNav : ResellerNav;
  const panelLabel = role === "admin" ? "Admin Panel" : role === "vendor" ? "Vendor Panel" : "Reseller Panel";

  const handleLogout = () => {
    logout.mutate(undefined, {
      onSuccess: () => {
        qc.clear();
        localStorage.removeItem("auth_token");
        navigate("/login");
      },
      onError: () => {
        qc.clear();
        localStorage.removeItem("auth_token");
        navigate("/login");
      }
    });
  };

  const SidebarContent = () => (
    <>
      {/* Brand */}
      <div className="px-5 pt-6 pb-4 border-b border-border">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-foreground flex items-center justify-center">
            <span className="text-background font-black text-sm">O</span>
          </div>
          <div>
            <div className="text-foreground font-bold text-sm leading-tight">Curato India</div>
            <div className="font-mono text-[11px] uppercase tracking-[0.08em] text-muted-foreground">{panelLabel}</div>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-4 overflow-y-auto space-y-0.5">
        {navItems.map(item => (
          <NavItem key={item.href} {...item} />
        ))}
      </nav>

      {/* User section */}
      <div className="px-3 pb-4 border-t border-border pt-3 space-y-1">
        {role === "Reseller" && (
          <Link href="/profile">
            <div className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-muted cursor-pointer">
              <div className="w-8 h-8 rounded-full bg-muted border border-border flex items-center justify-center">
                <span className="text-foreground text-xs font-bold">{user?.name?.charAt(0) ?? "U"}</span>
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-foreground text-xs font-medium truncate">{user?.name}</div>
                <div className="text-muted-foreground text-xs truncate">{user?.email}</div>
              </div>
            </div>
          </Link>
        )}
        {role !== "Reseller" && (
          <div className="flex items-center gap-3 px-3 py-2">
            <div className="w-8 h-8 rounded-full bg-background flex items-center justify-center">
              <span className="text-muted-foreground text-xs font-bold">{user?.name?.charAt(0) ?? "A"}</span>
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-foreground text-xs font-medium truncate">{user?.name}</div>
              <div className="text-muted-foreground text-xs">{role}</div>
            </div>
          </div>
        )}
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-3 py-2 rounded-lg text-muted-foreground hover:text-red-400 hover:bg-red-400/10 transition-all text-sm"
        >
          <LogOut size={16} />
          Sign out
        </button>
      </div>
    </>
  );

  return (
    <div className="flex flex-col lg:flex-row h-screen bg-background overflow-hidden">
      {/* Mobile Header */}
      <header className="lg:hidden flex items-center justify-between px-4 py-3 bg-background border-b border-border text-foreground z-30 shrink-0">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-foreground flex items-center justify-center">
            <span className="text-background font-black text-sm">O</span>
          </div>
          <div>
            <div className="text-foreground font-bold text-sm leading-tight">Curato India</div>
            <div className="font-mono text-[11px] uppercase tracking-[0.08em] text-muted-foreground">{panelLabel}</div>
          </div>
        </div>
        <button
          onClick={() => setIsMobileMenuOpen(true)}
          className="p-1.5 text-muted-foreground hover:text-foreground rounded-lg border border-border bg-background/50 cursor-pointer"
        >
          <Menu size={20} />
        </button>
      </header>

      {/* Mobile Drawer Backdrop */}
      {isMobileMenuOpen && (
        <div
          className="fixed inset-0 z-40 bg-foreground/40 backdrop-blur-xs lg:hidden"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}

      {/* Mobile Drawer Sidebar */}
      <aside className={cn(
        "fixed top-0 bottom-0 left-0 z-50 w-60 bg-background flex flex-col border-r border-border transition-transform duration-300 ease-in-out lg:hidden",
        isMobileMenuOpen ? "translate-x-0" : "-translate-x-full"
      )}>
        <div className="flex justify-end p-3 border-b border-border">
          <button
            onClick={() => setIsMobileMenuOpen(false)}
            className="p-1 text-muted-foreground hover:text-foreground rounded-lg cursor-pointer"
          >
            <X size={20} />
          </button>
        </div>
        <SidebarContent />
      </aside>

      {/* Desktop Sidebar (Permanent) */}
      <aside className="hidden lg:flex w-60 flex-shrink-0 bg-background flex-col border-r border-border">
        <SidebarContent />
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-y-auto">
        {children}
      </main>
    </div>
  );
}

