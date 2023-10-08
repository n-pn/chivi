<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Section from '$gui/sects/Section.svelte'

  import UpstemFull from '$gui/parts/upstem/UpstemFull.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ ustem, sroot } = data)

  $: is_owner = $_user.privi > 3 || $_user.vu_id == ustem.owner

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

{#if is_owner}
  <nav class="admin">
    <a href={sroot} class="m-btn _fill">
      <SIcon name="list" />
      <span class="-txt">Mục lục</span>
    </a>
    <a href="{sroot}/ul" class="m-btn _fill _success">
      <SIcon name="upload" />
      <span class="-txt">Đăng tải</span>
    </a>
    <a href="{sroot}/su" class="m-btn _fill _warning">
      <SIcon name="tools" />
      <span class="-txt">Quản lý</span>
    </a>
  </nav>
{/if}

<Section tabs={tabs[intab]} _now={ontab}>
  <slot />
</Section>

<style lang="scss">
  .admin {
    @include flex-ca($gap: 0.5rem);
    margin-bottom: 1rem;
  }
</style>
