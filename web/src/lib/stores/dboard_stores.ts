import { dialog_store } from '$utils/store_utils'

export const dboard_ctrl = {
  ...dialog_store({ actived: false, tab: 0 }),
  change_tab: (tab: number) => dboard_ctrl.update((x) => ({ ...x, tab })),
}
