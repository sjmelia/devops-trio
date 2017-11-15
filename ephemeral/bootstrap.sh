ephemeral_devices=
ephemerals=$(curl --silent http://169.254.169.254/2014-11-05/meta-data/block-device-mapping/ | grep ephemeral)
for ephemeral in $ephemerals; do
  device=$(curl --silent http://169.254.169.254/2014-11-05/meta-data/block-device-mapping/${ephemeral})
  # We only expect this to consistently work on Amazon AMIs because they will
  # symlink the device, see
  # http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
  ephemeral_devices=${ephemeral_devices}" /dev/$device"
done

pvcreate ${ephemeral_devices}
vgcreate ephemeral_vg ${ephemeral_devices}
lvcreate -l 100%FREE -n ephemeral_lv ephemeral_vg
mkfs.ext3 /dev/ephemeral_vg/ephemeral_lv
mkdir /opt/ephemeral
mount /dev/ephemeral_vg/ephemeral_lv /opt/ephemeral
