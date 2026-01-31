{
  config,
  pkgs,
  lib,
  ...
}: {
  # ===========================
  # Filesystem Optimizations
  # ===========================
  
  # Enable SSD TRIM for better performance and longevity
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # Note: Filesystem mount options are configured in hardware-configuration.nix
  # (noatime, commit=60 for better performance and battery life)

  # ===========================
  # Kernel Parameters & I/O
  # ===========================
  
  boot.kernel.sysctl = {
    # Memory management (balanced for laptop)
    "vm.swappiness" = 10; # Prefer RAM over swap (better performance, reasonable for 14GB RAM)
    "vm.vfs_cache_pressure" = 50; # Keep more filesystem cache
    "vm.dirty_ratio" = 10; # Start background writeback at 10% RAM
    "vm.dirty_background_ratio" = 5; # Background writes start at 5% RAM
    "vm.dirty_writeback_centisecs" = 1500; # Write every 15s (better for battery)
    
    # Network optimizations (better latency and throughput)
    "net.core.rmem_max" = 134217728; # 128MB receive buffer
    "net.core.wmem_max" = 134217728; # 128MB send buffer
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";
    "net.ipv4.tcp_congestion_control" = "bbr"; # Better TCP performance
    "net.core.default_qdisc" = "fq"; # Fair queue for BBR
    
    # Filesystem & inotify (important for development)
    "fs.inotify.max_user_watches" = 524288; # For large projects
    "fs.inotify.max_user_instances" = 512;
    "fs.file-max" = 2097152; # Max open files
  };

  # NVMe I/O scheduler and USB power management via udev
  services.udev.extraRules = ''
    # Set none scheduler for NVMe devices (optimal for NVMe SSDs)
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    
    # USB autosuspend for power saving (exclude input devices)
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    # Keep USB input devices awake
    ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="*[Kk]eyboard*", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="*[Mm]ouse*", ATTR{power/control}="on"
  '';

  # ===========================
  # CPU & Power Management
  # ===========================
  
  # Enable AMD P-State driver for better power/performance balance
  boot.kernelParams = [
    "amd_pstate=active" # Use AMD P-State EPP driver
  ];

  # ===========================
  # Nix Store Optimizations
  # ===========================
  
  nix.settings = {
    # Auto-optimize store (hard-link identical files)
    auto-optimise-store = true;
    
    # Parallel builds (adjust based on your CPU - you have 8 cores)
    max-jobs = "auto";
    cores = 6; # Leave 2 cores free for system responsiveness
    
    # Build cache and compression
    builders-use-substitutes = true;
    
    # Keep build logs compressed
    compress-build-log = true;
  };

  # Automatic garbage collection (keep system clean)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d"; # Keep last 2 weeks
  };

  # ===========================
  # System Journal & Logs
  # ===========================
  
  # Limit journal size to save SSD wear and space
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    SystemMaxFileSize=50M
    MaxRetentionSec=7day
  '';

  # ===========================
  # Laptop-Specific Power Savings
  # ===========================
  
  # Enable laptop mode for power saving
  powerManagement.enable = true;

  # ===========================
  # Additional Performance Tweaks
  # ===========================
  
  # Memory Management: Prevent system freezes under high memory pressure
  # ZRAM: Compressed RAM block for better memory efficiency
  zramSwap = {
    enable = true;
    memoryPercent = 50; # Use 50% of RAM for compressed swap
    algorithm = "zstd"; # Good balance of speed/compression for battery
  };

  # Physical Swap File: 16GB for heavy compilation/memory-intensive tasks
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024; # 16GB in MB
    }
  ];

  # EarlyOOM: Kill processes before system freezes
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # Kill processes when free memory < 5%
    freeSwapThreshold = 5; # Kill processes when free swap < 5%
    # Avoid killing critical system processes
    extraArgs = [
      "-g"
      "--avoid"
      "^(Hyprland|sddm|systemd.*|dbus.*|pipewire.*|wireplumber)$"
    ];
  };

  # Disable core dumps (save disk space and I/O)
  systemd.coredump.enable = false;

  # Faster boot
  systemd.services.systemd-udev-settle.enable = false;
  
  # Optimize systemd timeouts
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
    DefaultTimeoutStartSec=10s
  '';
}
