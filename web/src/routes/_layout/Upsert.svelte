<script context="module">
  export function suggest_urls(key) {
    return [
      { site: 'iCIBA', href: `https://www.iciba.com/${key}` },
      {
        site: 'Google Translation',
        href: `https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=vi&text=${key}`,
      },
      {
        site: 'Google',
        href: `https://www.google.com/search?q=${key}`,
      },
      {
        site: 'Baidu Fanyi',
        href: `https://fanyi.baidu.com/#zh/en/${key}`,
      },
      {
        site: 'Baike',
        href: `https://baike.baidu.com/item/${key}`,
      },
    ]
  }
</script>

<script>
  import { onMount, afterUpdate } from 'svelte'

  const tabs = [['special', 'Riêng'], ['generic', 'Chung']]

  export let active = true

  export let key = ''
  export let active_tab = 'special'
  export let unique_dic = 'combine'

  let field
  let val = ''

  $: active_dic = active_tab == 'special' ? unique_dic : 'generic'

  let links = []
  let props = {
    hanviet: 'test',
    pinyins: 'xx',
    generic: { value: '', mtime: null },
    special: { value: '', mtime: null },
    suggest: [],
  }

  onMount(() => field.focus())

  function change_tab(new_tab) {
    console.log({ new_tab })
    active_tab = new_tab
    field.focus()
  }

  async function upsert() {
    const res = await fetch(
      `/api/upsert?dic=${active_dic}&key=${key}&val=${val}`
    )
    active = false
  }

  async function remove() {
    const res = await fetch(`/api/delete?dic=${active_dic}&key=${key}`)
    active = false
  }

  async function inquire() {
    links = suggest_urls(key)

    const res = await fetch(`/api/inquire?key=${key}`)
    const data = await res.json()
    props = data
    val = props[active_tab].value || props.suggest[0] || props.hanviet
  }

  function capitalize(input) {
    return input.charAt(0).toUpperCase() + input.slice(1)
  }

  function upcase(count = 100) {
    const arr = val.split(' ')
    if (count > arr.length) count = arr.length

    for (let i = 0; i < count; i++) arr[i] = capitalize(arr[i])
    for (let i = count; i < arr.length; i++) arr[i] = arr[i].toLowerCase()

    val = arr.join(' ')
    field.focus()
  }
</script>

<style lang="scss">
  $gutter: 1rem;

  .container {
    position: fixed;
    display: flex;
    align-items: center;
    justify-content: center;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 999;
    @include bgcolor(rgba(#000, 0.6));
  }

  .dialog {
    width: rem(29);
    max-width: 100%;
    margin-top: -10%;
    @include bgcolor(white);
    @include radius();
    @include shadow(3);
  }

  $header-height: 3rem;
  $header-gutter: 0.5rem;

  header {
    padding: $header-gutter $gutter;
    height: $header-height;
    line-height: $header-height - $header-gutter * 2;

    @include bgcolor(color(neutral, 1));
    @include radius($pos: top);
    @include border($pos: bottom);

    .label {
      font-weight: 500;
    }
  }

  .tab {
    display: inline-block;
    cursor: pointer;
    text-transform: uppercase;
    margin-left: $header-gutter;
    font-weight: 500;
    padding: 0 0.75rem;
    height: $header-height - $header-gutter * 2;

    @include font-size(2);
    @include fgcolor(color(neutral, 6));

    @include radius();

    @include border();

    &._active {
      @include bgcolor(#fff);
      @include fgcolor(color(primary, 6));
      @include border-color($value: color(primary, 4));
    }
  }

  $label-width: 3rem;

  .key {
    padding: $gutter;
    border-bottom: 1px solid color(neutral, 2);
  }

  .key-inp {
    display: block;
    width: 100%;

    padding: 0 0.75rem;
    line-height: 2.5rem;

    @include radius();

    @include bgcolor(color(neutral, 1));
    @include border($color: color(neutral, 2));

    &:focus {
      @include bgcolor(white);
      @include border-color($value: color(primary, 3));
    }
    // line-height: 1rem;
  }

  .key-lit {
    margin-top: 0.375rem;
    @include font-size(2);
    line-height: 1;
    @include fgcolor(color(neutral, 7));
  }

  .val {
    padding: 0 $gutter;
  }

  .val-inp {
    display: block;
    width: 100%;
    min-height: 2.5rem;
    margin: 0;
    padding: 0.375rem 0.75rem;

    @include radius();
    @include border($color: color(neutral, 2));
    @include bgcolor(color(neutral, 1));
    &:focus,
    &:active {
      @include bgcolor(white);
      @include border-color($value: color(primary, 3));
    }
  }

  .val-act {
    // margin: 1rem 0;
    margin: 0.5rem 0;
    display: flex;
    .left {
      margin-right: auto;
    }
    .right {
      margin-left: auto;
    }
  }

  .cap {
    display: flex;
    line-height: 1.75rem;
    margin: 0.5rem 0;
  }

  .cap-lbl {
    padding: 0;
    padding-right: 0.375rem;
    max-width: 15vw;
    @include truncate(null);

    @include font-size(2);
    @include fgcolor(color(neutral, 5));
  }

  .cap-btn {
    padding: 0 0.375rem;
    max-width: 20vw;
    cursor: pointer;
    @include truncate(null);
    // text-transform: uppercase;
    @include font-size(2);
    // font-weight: 500;
    @include fgcolor(color(neutral, 6));
    // @include border($color: color(neutral, 3));
    @include radius();
    @include hover {
      @include bgcolor(color(primary, 1));
      @include fgcolor(color(primary, 6));
    }
  }

  footer {
    display: flex;
    @include bgcolor(color(neutral, 1));
    @include radius($pos: bottom);
    // width: 5rem;
    margin: 0;
    padding: 0 0.5rem;
    border-top: 1px solid color(neutral, 2);
    text-align: center;

    span,
    a {
      // display: inline-block;
      line-height: 1rem;
      padding: 0.5rem;
      @include font-size(2);
      // @include font-family(narrow);
    }

    a {
      @include fgcolor(color(neutral, 7));
      display: inline-block;
      border-left: 1px splid color(neutral, 3);

      @include hover {
        cursor: pointer;
        background-color: color(neutral, 3);
      }
    }
  }
</style>

<div class="container" on:click={() => (active = false)}>
  <div class="dialog" on:click={evt => evt.stopPropagation()}>
    <header>
      <span class="label">Thêm từ:</span>
      {#each tabs as [tab, lbl]}
        <span
          class="tab"
          class:_active={tab == active_tab}
          on:click={() => change_tab(tab)}>
          {lbl}
        </span>
      {/each}
    </header>

    <section class="key">
      <input
        class="key-inp"
        type="text"
        name="key"
        bind:value={key}
        on:change={inquire} />

      <div class="key-lit">
        <span class="pinyins">[{props.pinyins}]</span>
        <span class="hanviet">{props.hanviet}</span>
      </div>
    </section>

    <section class="val">
      <div class="cap">
        <span class="cap-lbl">Viết hoa:</span>
        <span class="cap-btn" on:click={() => upcase(0)}>không</span>
        <span class="cap-btn" on:click={() => upcase(1)}>1 chữ</span>
        <span class="cap-btn" on:click={() => upcase(2)}>2 chữ</span>
        <span class="cap-btn" on:click={() => upcase(3)}>3 chữ</span>
        <span class="cap-btn" on:click={() => upcase(99)}>toàn bộ</span>
      </div>

      <textarea
        lang="vi"
        class="val-inp"
        name="value"
        id="field"
        rows="2"
        bind:this={field}
        bind:value={val} />

      <div class="val-act">
        <div class="left" />

        <div class="right">
          <button
            type="button"
            class="m-button _text _harmful"
            on:click={remove}>
            <span>Xoá từ</span>
          </button>
          <button type="button" class="m-button _primary" on:click={upsert}>
            <!-- <svg class="m-icon _plus">
              <use xlink:href="/icons.svg#plus" />
            </svg> -->
            <span>{props[active_tab].value ? 'Sửa' : 'Thêm'}</span>
          </button>

        </div>
      </div>

    </section>

    <footer>
      <span>Tra từ:</span>
      {#each links as { site, href }}
        <a {href} target="_blank" rel="noopener noreferer">{site}</a>
      {/each}
    </footer>
  </div>
</div>
