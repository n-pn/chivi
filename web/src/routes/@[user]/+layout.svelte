<script lang="ts">
  import Section from '$gui/sects/Section.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: proot = `/@${data.vuser.uname}`

  $: tabs = [
    { type: 'home', href: `${proot}`, icon: 'message-2', text: 'Lời nhắn' },
    { type: 'book', href: `${proot}/books`, icon: 'books', text: 'Tủ truyện' },
    // { type: 'crit', href: `${proot}/crits`, icon: 'stars', text: 'Đánh giá' },
    // { type: 'list', href: `${proot}/lists`, icon: 'tags', text: 'Thư đơn' },
  ]
</script>

<Section {tabs}>
  <slot />
</Section>
