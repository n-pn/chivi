<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { upsert_memo } from '$lib/common/rdmemo'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Section from '$gui/sects/Section.svelte'
  import UserMemo from '$gui/shared/wnovel/UserMemo.svelte'

  import RmstemFull from '$gui/parts/rmstem/RmstemFull.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ rstem, sroot, crepo, rmemo } = data)

  // prettier-ignore
  $: tabs = {
    rd: [
      { type: 'ch', href: `${sroot}`, icon: 'list', text: 'Mục lục' },
      // { type: 'dl', href: `${sroot}/dl`, icon: 'download', text: 'Tải xuống' },
      { type: 'gd', href: `${sroot}/gd`, icon: 'message', text: 'Thảo luận' },
      // { type: 'st', href: `${sroot}/st`, icon: 'activity', text: 'Thay đổi' },
    ],
    ul: [
      { type: 'zh', href: `${sroot}/ul`, icon: 'upload', text: 'Text gốc' },
      { type: 'tl', href: `${sroot}/ul/tran`, icon: 'language', text: 'Bản dịch' },
      { type: 'md', href: `${sroot}/ul/data`, icon: 'tree', text: 'Ngữ pháp' },
      // { type: 'vd', href: `${sroot}/ul/term`, icon: 'package', text: 'Từ điển' },
    ],
    su: [
      { type: 'cf', href: `${sroot}/su`, icon: 'settings', text: 'Thiết đặt' },
      { type: 'rm', href: `${sroot}/su/redo`, icon: 'eraser', text: 'Tẩy xóa' },
      { type: 'lg', href: `${sroot}/su/xlog`, icon: 'lock-open', text: 'Mở khóa' },
    ],
  }

  $: ({ intab = 'rd', ontab = 'ch' } = $page.data)

  const trigger_liked = async () => {
    $rmemo.rd_track = $rmemo.rd_track < 1 ? data._user.privi + 1 : 0
    $rmemo = await upsert_memo($rmemo, 'rd_track')
  }
</script>

<RmstemFull {rstem} binfo={data.binfo || null} />
<UserMemo {crepo} {rmemo} />

<Section tabs={tabs[intab]} _now={ontab}>
  <slot />
</Section>
