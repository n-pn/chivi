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

  }

  $: ({ intab = 'rd', ontab = 'ch' } = $page.data)
</script>

<RmstemFull {rstem} binfo={data.binfo || null} />
<UserMemo {crepo} {rmemo} />

<Section tabs={tabs[intab]} _now={ontab}>
  <slot />
</Section>
