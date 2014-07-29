#!/bin/bash
# ==============================================================
# Скрипт для создания локального зеркала репозитория CENTOS 6.5
# ==============================================================

rsync -iavrt rsync://mirror.yandex.ru/centos/6.5/os/x86_64/ /home/mirror/centos/6.5/os/x86_64/
rsync -iavrt rsync://mirror.yandex.ru/centos/6.5/updates/x86_64/ /home/mirror/centos/6.5/updates/x86_64/
