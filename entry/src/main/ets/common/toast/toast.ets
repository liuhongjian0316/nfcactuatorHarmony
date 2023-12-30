import promptAction from '@ohos.promptAction';


export function showToast(
    message: string,
    duration: number = 2000
) {
  try {
    promptAction.showToast({
      message: `${message}`,
      duration,
    });
  } catch (error) {
    console.error(`showToast args error code is ${error.code}, message is ${error.message}`);
  }
}