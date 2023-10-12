<script context="module" lang="ts">
</script>

<script lang="ts">
  import { crumbs } from '$gui/global/Bcrumb.svelte'
  import Section from '$gui/sects/Section.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ viuser } = data)

  $: proot = `/@${viuser.uname}`
  $: $crumbs = [{ href: proot, text: 'Trang cá nhân của @' + viuser.uname }]

  $: tabs = [
    { type: 'home', href: `${proot}`, icon: 'message-2', text: 'Lời nhắn' },
    { type: 'book', href: `${proot}/books`, icon: 'books', text: 'Thư viện' },
    { type: 'crit', href: `${proot}/crits`, icon: 'stars', text: 'Đánh giá' },
    { type: 'list', href: `${proot}/lists`, icon: 'tags', text: 'Thư đơn' },
  ]
</script>

<Section {tabs}>
  <slot />
</Section>
