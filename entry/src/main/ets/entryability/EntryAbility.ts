import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import relationalStore from '@ohos.data.relationalStore';

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    globalThis.mainAbilityContext = this.context
    globalThis.globalConfig = {} as any // {"U1": {level:1, status: 1}}
    globalThis.staticProduct = ["U1", "U2", "U3", "R1", "R2", "E1", "E2", "Q", "newQ", "Z", "newZ", "newU2", "C2", "readOP", "resetSE", "MSP", "VF", "BFV"]
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // region Init database
    const STORE_CONFIG = {
      name: 'NFCRdb.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    // 建表
    const SQL_CREATE_DEVICE_TABLE = 'CREATE TABLE IF NOT EXISTS DEVICE (appId TEXT PRIMARY KEY, tel TEXT, code TEXT, beginTime TEXT, expireTime TEXT, exitTime TEXT, status TEXT)';
    const SQL_CREATE_CONFIG_TABLE = 'CREATE TABLE IF NOT EXISTS CONFIG (id TEXT PRIMARY KEY, keyname TEXT, status TEXT, level TEXT)';

    relationalStore.getRdbStore(this.context, STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
        return;
      }
      store.executeSql("show tables")
      store.executeSql(SQL_CREATE_DEVICE_TABLE);
      store.executeSql(SQL_CREATE_CONFIG_TABLE);
      globalThis.rdbStore = store
    });
    // endregion

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
