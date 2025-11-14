# JBS Installer Bug Fixes

## Проблемы

1. **Конфигурация кэша**: Инсталлятор записывал все три секции (memcache, memcached, redis) подряд без проверки расширений. Последняя запись перезаписывала предыдущие → в `host.ini` всегда `redis.port=6379`, даже если redis отсутствует.

2. **Создание симлинка**: Использовались относительные пути `./public`. В mod_php рабочая директория = директория скрипта → симлинк создавался в `/var/www/html/install/public` → невозможно удалить `/install`.

## Исправления

### Конфигурация кэша (строки 508-520)

```php
$CacheConfig = SPrintF("HostsIDs=%s",Implode(',',$HostsIDs));
if(Extension_Loaded('memcache'))
    $CacheConfig .= "\nmemcache.port=11211";
if(Extension_Loaded('memcached'))
    $CacheConfig .= "\nmemcached.port=11211";
if(Extension_Loaded('redis'))
    $CacheConfig .= "\nredis.port=6379";
if(!File_Put_Contents($File,$CacheConfig))
    Error(SPrintF('Ошибка записи файла (%s)',$File));
```

### Создание симлинка (строка 534)

```php
if(!@SymLink(SPrintF('%s/hosts/%s/tmp/public', SYSTEM_PATH, HOST_ID), SPrintF('%s/public', SYSTEM_PATH)))
```

## Применение

```bash
cd /path/to/jbs
patch -p0 < jbs_installer_complete_fix.patch
```

## Результат

- ✅ Корректная запись секции кэша в `host.ini`
- ✅ Симлинк `public` в правильной директории
- ✅ Успешное удаление `/install`
- ✅ Работа в mod_php и PHP-FPM
