import { DatabaseUpgradeSql, dbManager, initDatabaseConfig } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';
// TODO 将本地 kite_utils 改为线上版本，推送后删除然后git submodule init
// TODO 然后
// # 查看更改
// git status
// # 添加所有更改
// git add .
// # 提交
// git commit -m "docs: optimize all README.md files
//   - Add badges and quick start guide to main README
//   - Rewrite website README with tech stack and dev guide
//   - Create README for codeflash-harmony submodule
//   - Improve documentation structure"
// # 推送到 GitHub
// git push
/**
 * 数据库升级脚本配置
 * 注意：确保升级路径的连续性，每个版本都要有对应的升级脚本
 */
const upgradeSqls: DatabaseUpgradeSql[] = [];

/**
 * 初始化数据库管理器
 * @param context 应用上下文
 */
export function dbManagerInit(context: Context): void {
  initDatabaseConfig({
    dbName: 'codeflash_db',
    SecurityLevel: relationalStore.SecurityLevel.S3,
    dbSql: {
      "history": `CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        device TEXT NOT NULL
      );`
    },
    version: 1,
    upgradeSqls: upgradeSqls
  });

  dbManager.init(context);
  dbManager.createDatabaseStore();
}
