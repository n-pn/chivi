<script lang="ts">
  import { page } from '$app/stores'

  import Section from '$gui/sects/Section.svelte'
  import UserMemo from '$gui/shared/wnovel/UserMemo.svelte'

  import UpstemFull from '$gui/parts/upstem/UpstemFull.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ ustem, sroot, crepo, rmemo } = data)

  // prettier-ignore
  $: tabs = {
    rd: [
      { type: 'ch', href: `${sroot}`, icon: 'list', text: 'Mục lục' },
      { type: 'dl', href: `${sroot}/dl`, icon: 'download', text: 'Tải xuống' },
      { type: 'gd', href: `${sroot}/gd`, icon: 'message', text: 'Thảo luận' },
      { type: 'st', href: `${sroot}/st`, icon: 'activity', text: 'Thay đổi' },
    ],
    ul: [
      { type: 'zh', href: `${sroot}/ul`, icon: 'upload', text: 'Text gốc' },
      { type: 'tl', href: `${sroot}/ul/tran`, icon: 'language', text: 'Bản dịch' },
      { type: 'md', href: `${sroot}/ul/data`, icon: 'tree', text: 'Ngữ pháp' },
      { type: 'vd', href: `${sroot}/ul/term`, icon: 'package', text: 'Từ điển' },
    ],
    su: [
      { type: 'su', href: `${sroot}/su`, icon: 'ballpen', text: 'Thông tin' },
      { type: 'cf', href: `${sroot}/su/conf`, icon: 'settings', text: 'Thiết đặt' },
      { type: 'rm', href: `${sroot}/su/redo`, icon: 'eraser', text: 'Tẩy xóa' },
      { type: 'lg', href: `${sroot}/su/xlog`, icon: 'lock-open', text: 'Mở khóa' },
    ],
  }

  $: ({ intab = 'rd', ontab = 'ch' } = $page.data)
</script>

<UpstemFull {ustem} binfo={data.binfo || null} />

<UserMemo {crepo} {rmemo} />

<Section tabs={tabs[intab]} _now={ontab}>
  <slot />
</Section>
