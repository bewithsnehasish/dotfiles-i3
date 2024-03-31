# 🖥️ Mounting Windows Partition in Arch Linux

To access your Windows volume from Arch Linux and ensure it is accessible after rebooting, you need to mount the Windows partition. Here's how you can do it:

## Steps

### 1. Identify Windows Partition

First, identify the Windows partition you want to mount. You can do this by running:

```bash
lsblk
```

## 2. Create a Mount Point

You need to create a directory where the Windows partition will be mounted. For example:

```bash
sudo mkdir /mnt/windows
```

## 3. Mount the Windows Partition

Now, you can mount the Windows partition to the mount point you created. Replace `/dev/sdXn` with the actual partition identifier you found in step 1:

```bash
sudo mount /dev/sdXn /mnt/windows
```
## 4. Access the Windows Files

After mounting, you can access the Windows files by navigating to `/mnt/windows` in your file manager or terminal.

## 5. Make the Mount Permanent

To ensure the Windows partition is mounted automatically after rebooting, you need to add an entry to the `/etc/fstab` file. Open `/etc/fstab` in a text editor:

```bash
sudo nano /etc/fstab
```

## 6. Add a line at the end of the file to specify the mount point and other options. For example:

<i>Remember to check the partition number in which the windows is present and on the basis of that change the last <b>0</b> to the number the partition is having.</i>
```javascript
UUID=<UUID_of_Windows_partition> /mnt/windows ntfs defaults 0 0
```

Replace `<UUID_of_Windows_partition>` with the UUID of your Windows partition. You can find the UUID by running:

```bash
sudo blkid
```
#### This markdown provides clear instructions on replacing the placeholder `<UUID_of_Windows_partition>` with the actual UUID of the Windows partition by running `sudo blkid`. <br><hr>It also explains the purpose of this action in the context of making the mount permanent and provides additional information about the `/etc/fstab` file.
