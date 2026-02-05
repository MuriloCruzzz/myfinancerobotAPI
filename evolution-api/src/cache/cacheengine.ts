import { ICache } from '@api/abstract/abstract.cache';
import { CacheConf, ConfigService } from '@config/env.config';
import { Logger } from '@config/logger.config';

import { LocalCache } from './localcache';
import { RedisCache } from './rediscache';

const logger = new Logger('CacheEngine');

export class CacheEngine {
  private engine: ICache;

  constructor(
    private readonly configService: ConfigService,
    module: string,
  ) {
    const cacheConf = configService.get<CacheConf>('CACHE');

    if (cacheConf?.REDIS?.ENABLED && cacheConf?.REDIS?.URI !== '') {
      try {
        const redisEngine = new RedisCache(configService, module);
        if (redisEngine) {
          logger.verbose(`RedisCache initialized for ${module}`);
          this.engine = redisEngine;
        }
      } catch {
        if (cacheConf?.LOCAL?.ENABLED) {
          logger.verbose(`Redis not available, LocalCache initialized for ${module}`);
          this.engine = new LocalCache(configService, module);
        }
      }
    }
    if (!this.engine && cacheConf?.LOCAL?.ENABLED) {
      logger.verbose(`LocalCache initialized for ${module}`);
      this.engine = new LocalCache(configService, module);
    }
  }

  public getEngine() {
    return this.engine;
  }
}
